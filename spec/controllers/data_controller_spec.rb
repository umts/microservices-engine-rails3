# frozen_string_literal: true
require 'rails_helper'
require 'mse_spec_helper'

describe MicroservicesEngine::V1::DataController, type: :controller do
  routes { MicroservicesEngine::Engine.routes }
  def setup
    @routes = MicroservicesEngine::Engine.routes
  end

  before(:each) do
    MicroservicesEngine.build = '1.1.1'
    @data = build_basic_data
    # change this variable for tests. deep_dup doesn't work correctly
    # in rails 3, so cannot use that.
    @changed_data = build_basic_data
  end
  let :submit do
    post :register, @data
  end

  describe 'POST #register' do
    it 'responds' do
      submit
      expect(response.status).to be(200)
    end

    # Validating tokens
    describe 'validating token' do
      it 'accepts valid token' do
        # 1. Expect submitting the data to not cause any issues

        expect{ submit }.not_to raise_error
      end

      # This test is disabled until the router implements the appropriate logic
      # it 'denies invalid token' do
      # 1. Change base data to be an invalid token
      # 2. Expect the request to cause an error.

      #   @changed_data['token'] = 'mayonnaise_is_not_an_instrument_patrick'
      #   expect { process :register, method: :post, params: @changed_data }.to raise_error(SecurityError)
      # end
    end

    # The request updates the build version properly
    describe 'updating MicroservicesEngine.build' do
      context 'failing builds' do
        failing_semantic_builds.each do |failing_build|
          it "fails with older version #{failing_build}" do
            change_build(failing_build, @changed_data)
            expect{ post :register, @changed_data }.to raise_error(RuntimeError)
          end
        end
      end

      context 'passing builds' do
        passing_semantic_builds.each do |passing_build|
          it "passes with newer version #{passing_build}" do
            change_build(passing_build, @changed_data)
            expect(MicroservicesEngine.build).to eq('1.1.1')
            post :register, @changed_data
            expect(MicroservicesEngine.build).to eq(passing_build)
          end
        end
      end
    end

    # The request generates, modifies, and removes Connection
    # objects as expected
    describe 'resulting Connection models' do
      before(:each) do
        @connection = MicroservicesEngine::Connection
      end

      context 'before the request' do
        it 'has no objects' do
          expect(@connection.count).to be(0)
        end
      end

      describe 'new' do
        before(:each) do
          post :register, @data
        end

        it 'generates the models' do
          expect(@connection.count).to be(2)
        end

        it 'generated the names' do
          expect(@connection.all.map(&:name)).to eq(@data['content'].map{ |c| c['name'] })
        end

        it 'generated the urls' do
          expect(@connection.all.map(&:url)).to eq(@data['content'].map{ |c| c['url'] })
        end

        it 'generated the objects' do
          expect(@connection.all.map(&:object)).to eq(@data['content'].map{ |c| c['object'] })
        end

        it 'adds model when new data appears' do
          new_data = {
            'name' => 'Endpoint 2',
            'object' => 'Potatoes',
            'url' => 'pota://toe.sareawes.ome'
          }
          @changed_data['content'].append(new_data)

          expect { post :register, @changed_data }
            .to change { @connection.count }
            .by(1)
        end
      end

      describe 'editing' do
        before(:each) do
          submit
        end

        it 'updates the name' do
          @changed_data['content'][0]['name'] = 'Potatoes'
          expect { post :register, @changed_data }
            .to change { @connection.all.map(&:name) }
            .from(@data['content'].map{ |c| c['name'] })
            .to(@changed_data['content'].map{ |c| c['name'] })
        end

        it 'updates the url' do
          @changed_data['content'][0]['url'] = 'pota://toe.s/'
          expect { post :register, @changed_data }
            .to change { @connection.all.map(&:url) }
            .from(@data['content'].map{ |c| c['url'] })
            .to(@changed_data['content'].map{ |c| c['url'] })
        end

        it 'swaps information to other model' do
          @changed_data['content'][0]['object'] = 'SomeOtherObject'
          expect { post :register, @changed_data }
            .not_to change { @connection.count }
        end
      end

      describe 'removing' do
        before(:each) do
          post :register, @data
        end

        it 'removes the model' do
          @changed_data['content'].delete_at(0)
          expect { post :register, @changed_data }
            .to change { @connection.count }
            .by(-1)
        end
      end
    end
  end
end
