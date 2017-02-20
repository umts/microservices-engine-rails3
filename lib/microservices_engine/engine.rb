# frozen_string_literal: true
module MicroservicesEngineRails3
  class Engine < ::Rails::Engine
    isolate_namespace MicroservicesEngineRails3

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
