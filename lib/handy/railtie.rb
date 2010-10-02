module Handy
  class Engine < Rails::Engine

    initializer "handy.setup" do
    end

    rake_tasks do
      desc "lab99" do
        puts "You're in my_gem"
      end
    end
  end
end
