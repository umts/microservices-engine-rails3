# frozen_string_literal: true
require 'rails_helper'

describe MicroservicesEngine::Connection do
  describe 'self.get' do
    before :each do
      @resource = :example_model
      @path = [:action]
    end
    let :submit do
      MicroservicesEngine::Connection.get(@resource, @path)
    end
    context 'it finds a connection object with that resource' do
      before :each do
        @connection = MicroservicesEngine::Connection.create(
          url: 'http://example.com',
          object: 'example_model'
        )
      end
      it 'calls the instance method get with the full path' do
        stub_request(:get, "http://example.com/example_model/action")
        expect_any_instance_of(MicroservicesEngine::Connection)
          .to receive(:get).with('example_model/action', {})
        submit
      end
    end
    context 'there is no connection object with that resource' do
      before :each do
        @connection = MicroservicesEngine::Connection.create(
          url: 'http://example.com',
          object: 'not_the_right_model'
        )
      end
      it 'raises an argument error' do
        expect{ submit }.to raise_error ArgumentError, "Unknown resource #{@resource}"
      end
    end
  end
  
  describe 'get' do
    before :each do
      @connection = MicroservicesEngine::Connection.create(
        url: 'http://example.com/',
        object: 'example_model'
      )
    end
    let :submit do
      @connection.get('example_model/action')
    end
    context 'successful response' do
      it 'returns the body of the response' do
        stub_request(:get, "http://example.com/example_model/action")
          .to_return(status: 200, body: 'whatever')
        expect(submit).to eql 'whatever'
      end
    end
    context 'anything other than HTTPSuccess' do
      it 'raises an argument error' do
        stub_request(:get, "http://example.com/example_model/action")
          .to_return(status: 500, body: 'ALERT THIS IS BAD')
        expect{ submit }.to raise_error ArgumentError, 'ALERT THIS IS BAD'
      end
    end
  end
end
