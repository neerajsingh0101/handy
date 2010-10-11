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

end
