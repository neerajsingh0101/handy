
module Handy

  class Util
    attr_accessor :username, :password, :database
    def initialize(*args)
      @username, @password, @database = *args
    end

    def retrieve_db_info(database_yml_file, env)
      config = YAML.load_file(database_yml_file)
      [ config[env]['database'], config[env]['user'], config[env]['password'] ]
    end

    def mysql_command
      password.blank? ? "mysql -u #{user} #{database}" : "mysql -u #{user}  -p'#{password}' #{database}"
    end
    
    def self.execute_command(cmd)
      puts cmd
      system cmd
    end

  end

  class Engine < Rails::Engine

    initializer "handy.setup" do
    end

    rake_tasks do
      namespace :handy do
        namespace :db do


          desc "Load schema and data from a local sql file."
          task :restore => :environment do
            puts "Usage: rake handy:db:restore file=xxxxxxxxx.sql[.gz]"
            file_name = ENV['file']
            raise "file was not supplied. Check Usage." unless file_name
            restore_file = File.join(Rails.root, 'tmp', file_name)
            raise "file was not found" unless File.exists?(restore_file)

            db_info = retrieve_db_info("#{Rails.root}/config/database.yml")
            database, user, password = db_info
            util = Util.new(db_info)

            if restore_file =~ /\.gz/
              puts "decompressing backup"
              result = system("gzip -d #{restore_file}" )
              raise("backup decompression failed. msg: #{$?}" ) unless result
            end

            cmd = "#{util.mysql_command} < #{restore_file.gsub('.gz','')}"

            Util.execute_cmd(cmd)
            puts "database has been restored"
          end

          desc "bakup database to a file"
          task :backup => [:environment] do
            desc <<-DESC
            This task backups the database to a file. It will keep a maximum of 10 backed up copies.
            The files are backed up at shared directory on remote server.
            This task should be executed before any deploy to production.
            Files are backed at Rails.root/../../shared/db_backups on the remote server
            DESC

            timestamp = ENV['timestamp'] || Time.zone.now.strftime("%Y-%m-%d-%H-%M-%S")
            MAX_BACKUPS = 10
            file_name = "#{timestamp}.sql"
            backup_dir = File.join (Rails.root, '..', '..', 'shared', 'db_backups')

            backup_file = File.join(backup_dir, "#{file_name}.gz")

            FileUtils.mkdir_p(backup_dir) unless File.exists?(backup_dir) && File.directory?(backup_dir)

            database, user, password = retrieve_db_info("#{Rails.root}/config/database.yml")
            cmd = "mysqldump --opt --skip-add-locks -u#{user} -p#{password} #{database} >> #{file_name}"
            Util.execute_cmd(cmd)

            #-c --stdout write on standard output, keep original files unchanged
            #-q  quite
            #-9 best compression
            sh "gzip -q9 #{file_name}"
            sh "mv #{file_name}.gz  #{backup_file}"
            puts "Backup done at #{File.expand_path(backup_file)}"

            all_backups = Dir.glob(File.join(backup_dir,"*.gz"))

            # Dir.glob(File.join(backup_dir,"*.gz")).sort cannot be used because in some cases
            # timestamp is being passed from capistrano. Since capistrano does not support Time.zone.now
            # file names are not 100% reliable means to ensure the order in which files were created.
            all_backups_sorted = all_backups.sort {|a,b| File.new(a).mtime <=> File.new(b).mtime}
            all_backups_sorted = all_backups_sorted.reverse

            if all_backups_sorted.size > MAX_BACKUPS
              unwanted_backups = all_backups_sorted[MAX_BACKUPS..-1  ] || []
              unwanted_backups.each {|file| FileUtils.rm_rf(file); puts "deleted file #{file}";}
            end
          end

          private


          desc "Copy production database to staging database. Or copy data from any database to any other datbase."
          task :db2db => :environment  do
            puts "Usage: handy:db:db2db from_env=production to_env=staging"
            from_env = ENV['from_env'] || 'production'
            to_env = ENV['to_env']
            raise "to_env is not specified. Check Usage" if to_env.blank?
            file_name = "#{Rails.root}/tmp/#{from_env}.data"
            config_file =  "#{Rails.root}/config/database.yml"

            db_config = YAML.load_file(config_file)

            from_user = db_config[from_env]['username']
            from_password = db_config[from_env]['password']
            from_database =  db_config[from_env]['database']
            from_params = "-Q --add-drop-table -O add-locks=FALSE -O lock-tables=FALSE"

            cmd = "mysqldump -u #{from_user} -p#{from_password} #{from_params} #{from_database} > #{file_name} "
            puts cmd
            system cmd

            to_username = db_config[to_env]['username']
            to_password = db_config[to_env]['password']
            to_database =  db_config[to_env]['database']

            cmd = "mysql -u #{to_username} -p#{to_password} #{to_database} < #{file_name}"
            puts cmd
            system cmd

            puts "#{to_env} database has been restored with #{from_env} database"
          end



        end
      end
    end
  end
end
