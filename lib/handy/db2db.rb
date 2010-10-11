module Handy
  class Db2db
    def self.run(from_env, to_env, file)
      from_params = "-Q --add-drop-table -O add-locks=FALSE -O lock-tables=FALSE"
      from_util = Util.retrieve_db_info(from_env)
      cmd = from_util.mysqldump_command
      cmd << " #{from_params} #{from_util.database} > #{file} "
      Util.execute_cmd(cmd)

      to_util = Util.retrieve_db_info(to_env)
      cmd = to_util.mysql_command
      cmd << " < #{file}"
      Util.execute_cmd(cmd)

      Util.pretty_msg "#{to_env} database has been restored with #{from_env} database"
    end
  end
end
