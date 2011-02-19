Capistrano::Configuration.instance(:must_exist).load do

  # Usage:
  #
  # Following capistrano task will restore your local database with database from remote database
  # cap production db:restore_local
  namespace :db do
    desc 'restore local file with data from remote machine'
    task :restore_local do
      timestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
      send(run_method, "cd #{current_path} && rake handy:db:backup timestamp=#{timestamp} RAILS_ENV=#{stage} ")
      get "#{deploy_to}/current/tmp/#{timestamp}.sql.gz","tmp/#{timestamp}.sql.gz"
      system("rake handy:db:restore file='#{timestamp}.sql.gz'")
    end
  end

end
