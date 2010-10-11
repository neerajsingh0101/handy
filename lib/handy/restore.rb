module Handy
  class Restore
    def self.run(file, env)
      util = Util.retrieve_db_info(env)

      if file =~ /\.gz/
        puts "decompressing backup"
        result = system("gzip -d #{file}" )
        raise("backup decompression failed. msg: #{$?}" ) unless result
      end

      cmd = "#{util.mysql_command} < #{file.gsub('.gz','')}"

      Util.execute_cmd(cmd)
      Util.pretty_msg "database has been restored"
    end
  end
end
