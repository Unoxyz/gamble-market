# $LOAD_PATH.unshift File.expand_path("./../lib", __FILE__)
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
  # t.verbose = true
  t.warning = false
end

task :default => :test

desc "track log file"
task :log do
  sh 'tail -F log/app.log'
end

desc "run app"
task :run do
  sh 'ruby run.rb'
end
