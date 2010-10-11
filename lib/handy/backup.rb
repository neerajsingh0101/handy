module Handy

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
