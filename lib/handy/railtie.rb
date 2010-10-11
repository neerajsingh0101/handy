class Engine < Rails::Engine

  initializer :after_initialize do
  end

  rake_tasks do
    load 'handy/tasks.rb'
  end

end
