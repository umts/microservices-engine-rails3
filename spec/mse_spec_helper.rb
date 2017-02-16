# frozen_string_literal: true

# -- Changes that directly affect RSpec -- #
module RSpec
  module Mocks
    ::RSpec::Mocks::ExampleMethods.class_exec do
      def expect_only_instance_of(klass)
        expect(klass.count).to be(1)
        AnyInstanceExpectationTarget.new(klass)
      end
    end
  end
end
# ---------------------------------------- #

# Changes the build key of a request
# Params:
# +v+:: The value to change the key to
# +b+:: The build request to change
def change_build(v, b)
  b['build'] = v
end

# Takes in a series of semantic versions (major, minor, revision)
# changes and outputs a new semantic version based off of 1.1.1
# Params:
# +major+:: Change in major version
# +minor+:: Change in minor version
# +revision+:: Change in revision version
def relative_build(major, minor, revision)
  # Example usage:
  # relative_build(1, -1, 0) = 2.0.1
  # relative_build(0, 0, 0) = 1.1.1
  [major, minor, revision].map { |ver| 1 + ver }.join('.')
end

# Returns a basic set fo a build data for integration testing
def build_basic_data
  {
    'build' =>  '1.1.2',
    'token' =>  'TEST_ENV_VALID_TOKEN',
    'content' =>  [
      {
        'name' =>  'Endpoint 1',
        'object' =>  'FieldTrip',
        'url' =>  'http://example.com/microservices_engine/v1/data'
      },
      {
        'name' =>  'Endpoint 2',
        'object' =>  'Survey',
        'url' =>  'http://potatoes.com/microservices_engine/v1/data'
      }
    ]
  }
end

# Gives a list of all changes to a semantic build that are invalid
def failing_semantic_builds
  [0, -1]
    .repeated_permutation(3)
    .to_a.map { |bld| relative_build(*bld) } - ['1.1.1']
end

# Gives a list of all changes to a semantic build that are valid
def passing_semantic_builds
  base = [0, 1]
         .repeated_permutation(3)
         .to_a.map { |bld| relative_build(*bld) }
  base + ['2.0.0', '2.1.0', '2.0.1', '1.2.0']
end
