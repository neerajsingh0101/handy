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
      file_name = "#{Rails.root}/tmp/#{from_env}.data"
      config_file =  "#{Rails.root}/config/database.yml"

      from_params = "-Q --add-drop-table -O add-locks=FALSE -O lock-tables=FALSE"
      util = Util.retrieve_db_info("#{Rails.root}/config/database.yml", from_env)
      cmd = util.mysqldump_command
      cmd << " #{from_params} #{util.database} > #{file_name} "
      Util.execute_cmd(cmd)

      util2 = Util.retrieve_db_info("#{Rails.root}/config/database.yml", to_env)
      cmd = util.mysql_command
      cmd << " < #{file_name}"
      Util.execute_cmd(cmd)

      Util.pretty_msg "#{to_env} database has been restored with #{from_env} database"
    end

  end
end
