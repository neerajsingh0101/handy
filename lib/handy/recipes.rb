puts '*'*100
Capistrano::Configuration.instance(:must_exist).load do

  namespace :handy do
    namespace :deploy do
      task :boom do
        raise 'boom'
      end
    end
  end

  before "deploy:update_code", "handy:deploy:boom"
end
