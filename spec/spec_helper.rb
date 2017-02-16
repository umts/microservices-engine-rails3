# frozen_string_literal: true

unless ENV['RAILS_VERSION'] == '3'
  require 'pry-byebug'
else
  require 'pry'
end
require 'yaml'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
