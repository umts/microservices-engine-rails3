# frozen_string_literal: true
class InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def setup_initializer
    template 'mse_router_info.yml', 'config/mse_router_info.yml'
    copy_file 'microservices_engine.rb',
              'config/initializers/microservices_engine.rb'
    migration_template 'create_microservices_engine_connections.rb',
                       'db/migrate/create_microservices_engine_connections',
                       migration_version: migration_version
  end

  # idea for this is from the 'devise' gem by plataformatec
  def migration_version
    if Rails::VERSION::MAJOR >= 5
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end
  end

  def self.next_migration_number(path)
    unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
            else
                  @prev_migration_nr += 1
                    end
      @prev_migration_nr.to_s
  end

end
