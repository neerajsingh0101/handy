Capistrano::Configuration.instance(:must_exist).load do

  before "deploy:update_code", "user_confirmation_for_production_deployment"
  task :user_confirmation_for_production_deployment, roles => :app do
    if "#{stage}" == 'production'
      message = %Q{
        ****************************************************************************************************************
        * You are pushing to production.
        *
        * production is deployed from production branch. So make sure that you merged your changes to production branch.
        *
        * You have pushed your changes to github. Right.
        *
        * continue(y/n)
        ****************************************************************************************************************
      }
      answer = Capistrano::CLI.ui.ask(message)
      abort "deployment to production was stopped" unless answer == 'y'
    end
  end

end
