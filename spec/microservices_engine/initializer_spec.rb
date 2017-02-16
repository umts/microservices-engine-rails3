# frozen_string_literal: true
require 'spec_helper'
require 'rails_helper'
require 'generators/install/templates/microservices_engine'

describe MicroservicesEngine::Initializer do
  let :config_data do
    { 'name' => 'service_name',
      'uri' => 'service_url',
      'router_uri' => 'http://example.com',
      'security_token' => 'security token' }
  end
  let :response_data do
    [{ 'url' => 'sharklazers',
       'models' => [{ 'name' => 'sharks' }, { 'name' => 'lazers' }] }]
  end

  describe 'initialize!' do
    let(:call) { described_class.initialize! }
    context 'ENV has key DISABLE_ROUTER_CHECKIN' do
      it 'does nothing' do
        stub_const('ENV', 'DISABLE_ROUTER_CHECKIN' => 'bananas')
        expect(described_class).not_to receive :check_for_config_file!
        expect(described_class).not_to receive :check_in_with_router
        expect(described_class).not_to receive :update_connections_database
        call
      end
    end
    context 'otherwise' do
      it 'checks for a config file and parses it as YAML' do
        stub_request(:post, 'http://example.com/services/register')
          .to_return(body: response_data.to_json)
        stub_const 'MicroservicesEngine::Initializer::CONFIG_FILE', 'apples'
        expect(described_class).to receive(:check_for_config_file!)
          .with 'apples'
        expect(YAML).to receive(:load_file).with('apples')
          .and_return config_data
        call
      end
      it 'checks in with the router using the data from the config file' do
        allow(described_class).to receive(:check_for_config_file!)
          .and_return nil
        allow(YAML).to receive(:load_file).and_return config_data
        allow(JSON).to receive(:parse).and_return response_data
        response = double code: '200', body: 'body'
        expect(described_class).to receive(:check_in_with_router)
          .and_return response
        call
      end
      it "raises an exception if the router's response code was not 200" do
        allow(described_class).to receive(:check_for_config_file!)
          .and_return nil
        allow(YAML).to receive(:load_file).and_return config_data
        allow(JSON).to receive(:parse).and_return response_data
        stub_request(:post, 'http://example.com/services/register')
          .to_return(status: [500, 'Internal Server Error'])
        expect { call }
          .to raise_error(RuntimeError, 'The router API response was invalid')
      end
      it 'updates the connections database using the response from the router' do
        allow(described_class).to receive(:check_for_config_file!)
          .and_return nil
        allow(YAML).to receive(:load_file).and_return config_data
        allow(JSON).to receive(:parse).and_return response_data
        response = double code: '200', body: 'body'
        allow(described_class).to receive(:check_in_with_router)
          .and_return response
        expect(described_class).to receive(:update_connections_database)
        call
      end
    end
  end

  describe 'check_for_config_file!' do
    let(:filepath) { 'some_filepath' }
    let(:call) { described_class.check_for_config_file! filepath }
    it 'looks for a file at the given path' do
      expect(File).to receive(:file?).with(filepath).and_return true
      call
    end
    it "raises an IOError if it can't find one" do
      expect(File).to receive(:file?).with(filepath).and_return false
      expect { call }.to raise_error IOError
    end
    it 'includes the filepath in the exception' do
      expect(File).to receive(:file?).with(filepath).and_return false
      expect { call }.to raise_error IOError, /#{filepath}/
    end
  end

  describe 'check_in_with_router' do
    let(:call) { described_class.check_in_with_router using: config_data }
    it 'makes a Net::HTTP POST request and returns the response' do
      expect(Net::HTTP).to receive(:post_form).and_return 'some response'
      expect(call).to eql 'some response'
    end
    it 'sends the request to the provided router_uri + /services/register' do
      router_address = config_data['router_uri']
      endpoint_address = router_address + '/services/register'
      endpoint_uri = URI.parse(endpoint_address)
      expect(Net::HTTP).to receive(:post_form).with endpoint_uri, anything
      call
    end
    it 'includes the service name, url, and security token in the params' do
      expected_params = { name: config_data['name'], url: config_data['uri'],
                          security_token: config_data['security_token'] }
      expect(Net::HTTP).to receive(:post_form)
        .with anything, hash_including(expected_params)
      call
    end
    it 'includes any accessible models, if they exist' do
      config_data['accessible_models'] = 'apples, bananas'
      expect(Net::HTTP).to receive(:post_form)
        .with anything, hash_including(models: 'apples, bananas')
      call
    end
  end

  describe 'report_missing_config_key' do
    let(:call) { described_class.report_missing_config_key :bananas }
    it 'raises an ArgumentError' do
      expect { call }.to raise_error ArgumentError
    end
    it 'includes the missing key in the exception' do
      expect { call }.to raise_error ArgumentError, /bananas/
    end
    it 'includes the location of the config file in the exception' do
      stub_const 'MicroservicesEngine::Initializer::CONFIG_FILE', 'apples'
      expect { call }.to raise_error ArgumentError, /apples/
    end
  end

  describe 'update_connections_database' do
    let :call do
      described_class.update_connections_database(with: response_data)
    end
    let(:connection_class) { MicroservicesEngine::Connection }
    it 'destroys all previous connection objects' do
      expect(connection_class).to receive(:destroy_all).once
      call
    end
    it 'creates a new connection object for each url/model pair' do
      expect { call }.to change { connection_class.count }.from(0).to(2)
    end
  end
end
