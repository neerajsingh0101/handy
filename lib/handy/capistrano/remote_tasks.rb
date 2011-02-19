Capistrano::Configuration.instance(:must_exist).load do

  # Usage:
  #
  # cap production remote 'tail -f log/production.log'
  # cap production rake 'db:prod2staging'

  set :sudo_call, ''

  desc 'makes remote/rake calls to be executed with sudo'
  task :use_sudo do
    set :sudo_call, 'sudo'
  end

  desc 'run rake task'
  task :rake do
    ARGV.values_at(Range.new(ARGV.index('rake')+1,-1)).each do |task|
      run "cd #{current_path}; #{sudo_call} RAILS_ENV=#{stage} rake #{task}"
    end
    exit(0)
  end

  desc 'run remote command'
  task :remote do
    command=ARGV.values_at(Range.new(ARGV.index('remote')+1, -1))
    run "cd #{current_path}; #{sudo_call} RAILS_ENV=#{stage} #{command*' '}"
    exit(0)
  end

  desc 'run specified rails code on server'
  task :runner do
    command=ARGV.values_at(Range.new(ARGV.index('runner')+1, -1))
    run "cd #{current_path}; RAILS_ENV=#{stage} rails runner '#{command*' '}'"
    exit(0)
  end

end
