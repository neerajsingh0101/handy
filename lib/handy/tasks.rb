namespace :handy do
  namespace :web do
    desc "Ping a site"
    task :ping => :environment do
      begin
        puts "Usage: rake handy:web:ping site=www.xxx.com"
        site = ENV['site']
        cmd = "curl http://#{site}> /dev/null 2>&1 &"
        system(cmd)
      rescue => e
        HoptoadNotifier.notify(e, :parameters => {:site => site})
        puts e.message + e.backtrace.join('\n')
      end
    end
  end

  namespace :db do

    desc "Load schema and data from a local sql file."
    task :restore => :environment do
      begin
        puts "Usage: rake handy:db:restore file=xxxxxxxxx.sql[.gz]"
        file_name = ENV['file']
        raise "file was not supplied. Check Usage." unless file_name
        file = File.join(Rails.root, 'tmp', file_name)
        raise "file was not found" unless File.exists?(file)
        Rake::Task["db:drop"].invoke
        Rake::Task["db:create"].invoke

        Handy::Restore.run(file, Rails.env)
      rescue => e
        HoptoadNotifier.notify(e, :parameters => {:file => file})
        puts e.message + e.backtrace.join('\n')
      end
    end

    desc <<-DESC
    This task backups the database to a file. It will keep a maximum of 10 backed up copies.
    The files are backed up at shared directory on remote server.
    This task should be executed before any deploy to production.
    Files are backed at Rails.root/../../shared/db_backups on the remote server
    DESC
    task :backup => [:environment] do
      begin
        timestamp = ENV['timestamp'] || Time.zone.now.strftime("%Y-%m-%d-%H-%M-%S")
        file = "#{timestamp}.sql"
        backup_dir = File.join (Rails.root, 'tmp')
        FileUtils.mkdir_p(backup_dir) unless File.exists?(backup_dir) && File.directory?(backup_dir)
        backup_file = File.join(backup_dir, "#{file}.gz")

        Handy::Backup.run(Rails.env, file, backup_file)
      rescue => e
        HoptoadNotifier.notify(e, :parameters => {:file => file})
        puts e.message + e.backtrace.join('\n')
      end
    end


    desc "Copy production database to staging database. Or copy data from any database to any other datbase."
    task :db2db => :environment  do
      begin
        puts "Usage: handy:db:db2db from_env=production to_env=staging"
        from_env = ENV['from_env'] || 'production'
        to_env = ENV['to_env'] || 'staging'
        file = "#{Rails.root}/tmp/#{from_env}.data"

        Handy::Db2db.run(from_env, to_env, file)
      rescue => e
        HoptoadNotifier.notify(e, :parameters => {:from_env => from_env, :to_env => to_env })
        puts e.message + e.backtrace.join('\n')
      end
    end

    desc "Copy database dump to s3"
    task :dump2s3 => :environment  do
      begin
        timestamp = Time.zone.now.strftime("%Y-%m-%d-%H-%M-%S")
        file = "#{timestamp}.sql.gz"
        ENV['file'] = file
        Rake::Task["handy:db:backup"].invoke

        Handy::Dump2s3.run(Rails.env, file)
      rescue => e
        HoptoadNotifier.notify(e, :parameters => {:file => file})
        puts e.message + e.backtrace.join('\n')
      end
    end

    namespace :dump2s3 do

      desc "list all files stored at s3"
      task :list => :environment  do
        begin
          Handy::Dump2s3.list(Rails.env)
        rescue => e
          HoptoadNotifier.notify(e)
          a = e.message.inspect
          b = e.backtrace.join('\n')
          puts a.inspect
          puts b.inspect
          puts a.class.name
          puts b.class.name
          puts a + b
        end
      end

      desc "restore data from s3"
      task :restore => :environment  do
        begin
          file = ENV['file']
          raise "No file was specified. Usage: rake handy:db:dump2s3:restore file=xxxx" if file.blank?
          Handy::Dump2s3.restore(Rails.env, file)
          Rake::Task["handy:db:restore"].invoke
        rescue => e
          HoptoadNotifier.notify(e, :parameters => {:file => file})
          puts e.message + e.backtrace.join('\n')
        end
      end

    end

  end
end
