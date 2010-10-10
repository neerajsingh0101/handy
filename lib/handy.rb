require 'handy/railtie'

module Handy

  class Util
    attr_accessor :username, :password, :database
    def initialize(*args)
      @username, @password, @database = *args
    end

    def self.retrieve_db_info(env)
      config = YAML.load_file(Rails.root.join('config', 'database.yml'))
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

  class Restore
    def self.run(file, env)
      util = Util.retrieve_db_info(env)

      if file =~ /\.gz/
        puts "decompressing backup"
        result = system("gzip -d #{file}" )
        raise("backup decompression failed. msg: #{$?}" ) unless result
      end

      cmd = "#{util.mysql_command} < #{restore_file.gsub('.gz','')}"

      Util.execute_cmd(cmd)
      Util.pretty_msg "database has been restored"
    end
  end

  class Backup
    def self.run(env, file, backup_file)
      util = Util.retrieve_db_info(env)
      cmd = util.mysqldump_command
      cmd << " --opt --skip-add-locks #{util.database} >> #{file}"
      Util.execute_cmd(cmd)

      #-c --stdout write on standard output, keep original files unchanged
      #-q  quite
      #-9 best compression
      Util.execute_cmd "gzip -q9 #{file}"
      Util.execute_cmd "mv #{file}.gz  #{backup_file}"
      Util.pretty_msg "Backup done at #{File.expand_path(backup_file)}"
    end
  end

end
