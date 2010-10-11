namespace :handy do
  namespace :db do

    desc "Load schema and data from a local sql file."
    task :restore => :environment do
      puts "Usage: rake handy:db:restore file=xxxxxxxxx.sql[.gz]"
      file_name = ENV['file']
      raise "file was not supplied. Check Usage." unless file_name
      file = File.join(Rails.root, 'tmp', file_name)
      raise "file was not found" unless File.exists?(file)

      Handy::Restore.run(file, Rails.env)
    end

    desc <<-DESC
    This task backups the database to a file. It will keep a maximum of 10 backed up copies.
    The files are backed up at shared directory on remote server.
    This task should be executed before any deploy to production.
    Files are backed at Rails.root/../../shared/db_backups on the remote server
    DESC
    task :backup => [:environment] do
      timestamp = ENV['timestamp'] || Time.zone.now.strftime("%Y-%m-%d-%H-%M-%S")
      file = "#{timestamp}.sql"
      backup_dir = File.join (Rails.root, 'tmp')
      FileUtils.mkdir_p(backup_dir) unless File.exists?(backup_dir) && File.directory?(backup_dir)
      backup_file = File.join(backup_dir, "#{file}.gz")

      Handy::Backup.run(Rails.env, file, backup_file)
    end


    desc "Copy production database to staging database. Or copy data from any database to any other datbase."
    task :db2db => :environment  do
      puts "Usage: handy:db:db2db from_env=production to_env=staging"
      from_env = ENV['from_env'] || 'production'
      to_env = ENV['to_env'] || 'staging'
      file = "#{Rails.root}/tmp/#{from_env}.data"

      Handy::Db2db.run(from_env, to_env, file)
    end

    desc "Copy database dump to s3"
    task :dump2s3 => :environment  do
      timestamp = Time.zone.now.strftime("%Y-%m-%d-%H-%M-%S")
      file = "#{timestamp}.sql.gz"
      ENV['file'] = file
      Rake::Task["handy:db:backup"].invoke

      Handy::Dump2s3.run(Rails.env, file)
    end

    namespace :dump2s3 do

      desc "list all files stored at s3"
      task :list => :environment  do
        Handy::Dump2s3.list(Rails.env)
      end

      desc "restore data from s3"
      task :restore => :environment  do
        file = ENV['file']
        raise "No file was specified. Usage: rake handy:db:dump2s3:restore file=xxxx" if file.blank?
        Handy::Dump2s3.restore(Rails.env, file)
        Rake::Task["handy:db:restore"].invoke
      end

    end

  end
end
