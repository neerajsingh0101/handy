require 'rubygems'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test handy gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

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
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "handy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
