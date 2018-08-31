require 'httpclient'
require 'uri'
require 'cloud_controller/diego/staging_request'
require 'cloud_controller/opi/helpers'

module OPI
  class StagerClient
    def initialize(opi_url, config)
      @client = HTTPClient.new(base_url: URI(opi_url))
      @config = config
    end

    def stage(staging_guid, staging_details)
      staging_request = to_request(staging_details)
      payload = MultiJson.dump(staging_request.message)

      response = @client.post("/stage/#{staging_guid}", body: payload)
      if response.status_code != 200
        response_json = OPI.recursive_ostruct(JSON.parse(response.body))
        raise CloudController::Errors::ApiError.new_from_details('RunnerError', response_json)
      end
    end

    def stop_staging(staging_guid); end

    private

    def to_request(staging_details)
      VCAP::CloudController::Diego::Protocol.new.stage_package_request(@config, staging_details)
    end
  end
end
