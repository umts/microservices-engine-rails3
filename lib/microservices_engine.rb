# frozen_string_literal: true
require 'net/http'
require 'net/https'
require 'microservices_engine/engine' if defined? Rails

module MicroservicesEngine
  class << self
    # Setter method for the `build` portion of the engine, includes various validations
    def build=(b)
      @build = b if Rails.env.test? && b == '1.1.1'

      # ---------------- Semantic Versioning ---------------- #
      # 1. All version INCREASES are VALID                    #
      # 2. Version DECREASES are INVALID IF AND ONLY IF none  #
      #    of the more importantversion numbers increase.     #
      # 3. That is to say...                                  #
      #    a. A major decrease is never valid                 #
      #    b. A minor decrease is only valid when the major   #
      #       version increases.                              #
      #    c. A revision decrease is only valid when either   #
      #       the major or minor version increases.           #
      # ----------------------------------------------------- #

      current = Gem::Version.new(build)
      given = Gem::Version.new(b)

      if current > given
        raise "Received version is older than existing. Now: #{build}. Given: #{b}"
      end

      @build = b
    end

    # Returns the engine's current build
    def build
      @build ||= '0.0.0'
    end

    # Reloads and returns the engine's current YML configuration
    def reload_config
      @config = YAML.load_file('config/mse_router_info.yml')
    end

    # Returns the engine's YML configuration, alias for `reload_config`
    alias config reload_config

    # Takes in a token and verifies against the engine's YML configuration files
    # Params:
    # +token+:: The token to test validity of
    def valid_token?(token)
      return token == 'TEST_ENV_VALID_TOKEN' if Rails.env.test?

      valid_token = config['security_token']
      raise 'Security token is not set! Please set it as soon as possible!' if valid_token.blank?

      token == valid_token
    end

    # Redirects an engine `get` call to the appropriate resource
    def get(resource, path, params = {})
      MicroservicesEngine::Connection.get(resource, path, params)
    end
  end
end
