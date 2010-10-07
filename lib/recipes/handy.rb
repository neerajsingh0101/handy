namespace :handy do
  namespace :deploy do
    task :boom do
      raise 'boom'
    end
  end
end

#Capistrano::Configuration.instance(:must_exist).load do
  #before "deploy:update_code", "handy:deploy:boom"
#end
  before "deploy:update_code", "handy:deploy:boom"
