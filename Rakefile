require 'rubygems'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

begin
  require 'jeweler'
  require './lib/handy/version'
  Jeweler::Tasks.new do |gem|
    gem.name = "handy"
    gem.version = Handy::VERSION
    gem.summary = %Q{handy tools}
    gem.description = %Q{handy tools that gets job done}
    gem.email = "neerajdotname@gmail.com"
    gem.homepage = "http://github.com/neerajdotname/handy"
    gem.authors = ["Neeraj Singh"]
    gem.files = FileList["[A-Z]*", "{lib,test}/**/*", 'init.rb']

    gem.add_dependency('aws', '>= 2.3.21')
    gem.add_dependency('capistrano', '>= 2.5.19')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


desc 'Test handy gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
