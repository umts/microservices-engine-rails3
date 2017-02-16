# frozen_string_literal: true
source 'https://rubygems.org'

# Declare your gem's dependencies in microservices_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

case ENV['RAILS_VERSION']
when '3'
  eval_gemfile ::File.join(::File.dirname(__FILE__), 'gemfiles/rails_3.gemfile')
when '4'
  eval_gemfile ::File.join(::File.dirname(__FILE__), 'gemfiles/rails_4.gemfile')
when '5'
  eval_gemfile ::File.join(::File.dirname(__FILE__), 'gemfiles/rails_5.gemfile')
end

group :development do
  gem 'bundler'
  gem 'rake'
end

group :newruby do
  gem 'pry-byebug'
  gem 'rubocop', '~> 0.45'
end
