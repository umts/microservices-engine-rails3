# frozen_string_literal: true
require_dependency 'microservices_engine/application_controller'

module MicroservicesEngineRails3
  module V1
    class DataController < ApplicationController
      def register
        # TO-DO
        # . . .

        # Current assumption of example request format
        #
        # {
        #     'build': 1.0.0,
        #     'token': 'a72!j*^bQ34dE%SS$#haBd%67#cD',
        #     'content': {
        #       {
        #         'name': 'Endpoint 1'
        #         'object': 'FieldTrip'
        #         'url': 'http://example.com/microservices_engine/v1/data'
        #       },
        #       {
        #         'name': 'Endpoint 2'
        #         'object': 'Survey'
        #         'url': 'http://potatoes.com/microservices_engine/v1/data'
        #       }
        #     }
        # }
        #

        data = params['content']
        data_objects = data.map { |d| d['object'] }

        # Disabled until router implements token authorization
        # verify_token(params['token'])
        verify_build(params['build'])

        existing = Connection.all
        in_request = existing.dup.to_a.keep_if { |c| data_objects.include? c.object }
        not_in_request = existing - in_request

        # Remove all objects not included in the request
        not_in_request.each do |unwanted|
          Connection.destroy(unwanted.id)
        end

        # 'Find and update' or 'Create' all remaining models
        data.each do |endpoint|
          desired = Connection.where(object: endpoint['object']).first
          if desired.present?
            desired.update_attributes(
              name: endpoint.require('name'),
              url: endpoint.require('url')
            )
          else
            Connection.create(
              name: endpoint.require(:name),
              url: endpoint.require(:url),
              object: endpoint.require(:object)
            )
          end
        end
        render json: { response: 200 }, status: :ok
      end

      private

      def verify_token(token)
        raise SecurityError, '(Stub) Invalid Token' unless MicroservicesEngineRails3.valid_token?(token)
      end

      def verify_build(build)
        # The build= method already has verification built-in
        MicroservicesEngineRails3.build = build
      end
    end
  end
end
