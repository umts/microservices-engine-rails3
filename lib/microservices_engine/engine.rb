# frozen_string_literal: true
module MicroservicesEngine
  class Engine < ::Rails::Engine
    isolate_namespace MicroservicesEngine

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
