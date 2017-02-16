# frozen_string_literal: true
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

case ENV['RAILS_VERSION']
when '3'
  APP_RAKEFILE = File.expand_path('../test/rails3dummy/Rakefile', __FILE__)
when '4'
  APP_RAKEFILE = File.expand_path('../test/rails4dummy/Rakefile', __FILE__)
when '5'
  APP_RAKEFILE = File.expand_path('../test/dummy/Rakefile', __FILE__)
end
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task default: :test
