class Util
  attr_accessor :username, :password, :database
  def initialize(*args)
    @username, @password, @database = *args
  end

  def self.retrieve_db_info(database_yml_file, env)
    config = YAML.load_file(database_yml_file)
    self.new(config[env]['username'], config[env]['password'], config[env]['database'])
  end

  def mysql_command
    a = ['mysql']
    a << "-u #{username}"
    a << "-p'#{password}'" unless password.blank?
    a << database
    a.join(' ')
  end

  def mysqldump_command
    a = ['mysqldump']
    a << "-u #{username}"
    a << "-p'#{password}'" unless password.blank?
    a.join(' ')
  end

  def self.execute_cmd(cmd)
    puts "executing: #{cmd}"
    system cmd
  end

  def self.pretty_msg(msg)
    puts ''
    puts '*'*100
    puts ('*' << ' '*5 << msg)
    puts '*'*100
    puts ''
  end

end

namespace :handy do
  namespace :db do

    desc "Load schema and data from a local sql file."
    task :restore => :environment do
      puts "Usage: rake handy:db:restore file=xxxxxxxxx.sql[.gz]"
      file_name = ENV['file']
      raise "file was not supplied. Check Usage." unless file_name
      restore_file = File.join(Rails.root, 'tmp', file_name)
      raise "file was not found" unless File.exists?(restore_file)

      util = Util.retrieve_db_info("#{Rails.root}/config/database.yml", Rails.env)

      if restore_file =~ /\.gz/
        puts "decompressing backup"
        result = system("gzip -d #{restore_file}" )
        raise("backup decompression failed. msg: #{$?}" ) unless result
      end

      cmd = "#{util.mysql_command} < #{restore_file.gsub('.gz','')}"

      Util.execute_cmd(cmd)
      Util.pretty_msg "database has been restored"
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
      file_name = "#{timestamp}.sql"
      backup_dir = File.join (Rails.root, 'tmp')

      backup_file = File.join(backup_dir, "#{file_name}.gz")

      FileUtils.mkdir_p(backup_dir) unless File.exists?(backup_dir) && File.directory?(backup_dir)

      util = Util.retrieve_db_info("#{Rails.root}/config/database.yml", Rails.env)
      cmd = util.mysqldump_command
      cmd << " --opt --skip-add-locks #{util.database} >> #{file_name}"
      #cmd = "mysqldump --opt --skip-add-locks -u#{user} -p#{password} #{database} >> #{file_name}"
      Util.execute_cmd(cmd)

      #-c --stdout write on standard output, keep original files unchanged
      #-q  quite
      #-9 best compression
      #sh "gzip -q9 #{file_name}"
      Util.execute_cmd "gzip -q9 #{file_name}"
      #sh "mv #{file_name}.gz  #{backup_file}"
      Util.execute_cmd "mv #{file_name}.gz  #{backup_file}"
      
      Util.pretty_msg "Backup done at #{File.expand_path(backup_file)}"

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
