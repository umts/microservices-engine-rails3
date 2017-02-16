# frozen_string_literal: true
require 'spec_helper'

class MicroservicesEngineTest < ActiveSupport::TestCase
  describe MicroservicesEngine do
    before(:each) do
      MicroservicesEngine.build = '1.1.1'
      @expected = {
        'name' =>  '',
        'uri' =>  '',
        'security_token' =>  '',
        'router_uri' =>  '',
        'accessible_models' =>  ''
      }
      allow(MicroservicesEngine).to receive(:config).and_return(@expected)
      allow(MicroservicesEngine).to receive(:reload_config).and_return(@expected)
    end

    describe 'build= and build' do
      context 'failing builds' do
        failing_semantic_builds.each do |failing_build|
          it "fails with older version #{failing_build}" do
            expect { MicroservicesEngine.build = failing_build }.to raise_error(RuntimeError)
          end
        end
      end

      context 'passing builds' do
        passing_semantic_builds.each do |passing_build|
          it "passes with newer version #{passing_build}" do
            expect(MicroservicesEngine.build).to eq('1.1.1')
            MicroservicesEngine.build = passing_build
            expect(MicroservicesEngine.build).to eq(passing_build)
          end
        end
      end
    end

    # Because they are alias methods, both are tested at once
    describe 'reload_config and config' do
      # With this test, we can effectively only test
      # one of the methods and actually be testing both
      it 'does the same thing' do
        expect(MicroservicesEngine.reload_config)
          .to be(MicroservicesEngine.config)
      end

      it 'loads the config' do
        expect(MicroservicesEngine.config)
          .to eq(@expected)
      end

      it 'loads the new config' do
        @expected['name'] = 'potatoes'
        expect(MicroservicesEngine.config)
          .to eq(@expected)
      end
    end

    describe 'valid_token?' do
      context 'on test environment' do
        it 'accepts valid token' do
          expect(MicroservicesEngine.valid_token?('TEST_ENV_VALID_TOKEN'))
            .to be(true)
        end

        it 'refuses invalid token' do
          expect(MicroservicesEngine.valid_token?('POTATOES_ARE_INVALID'))
            .to be(false)
        end
      end

      context 'not on test environment' do
        before(:each) do
          @expected['security_token'] = 'PROD_ENV_VALID_TOKEN'
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        end

        it 'raises an error with no token config' do
          @expected['security_token'] = ''
          expect { MicroservicesEngine.valid_token?(' => thinking:') }
            .to raise_error(RuntimeError)
        end

        it 'accepts valid token' do
          expect(MicroservicesEngine.valid_token?('PROD_ENV_VALID_TOKEN'))
            .to be(true)
        end

        it 'refuses invalid token' do
          expect(MicroservicesEngine.valid_token?('POTATOES_ARE_STILL_INVALID'))
            .to be(false)
        end
      end
    end
  end
end
