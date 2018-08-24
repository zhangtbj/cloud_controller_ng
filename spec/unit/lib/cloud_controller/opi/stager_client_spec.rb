require 'spec_helper'
require 'cloud_controller/opi/stager_client'
require 'cloud_controller/diego/staging_request'

RSpec.describe(OPI::StagerClient) do
  let(:eirini_url) { 'http://eirini.loves.heimdall:777' }
  subject(:stager_client) { described_class.new(eirini_url) }

  context 'when staging an app' do
    before do
      stub_request(:post, "#{eirini_url}/stage/guid").
        to_return(status: 200)
    end

    it 'should send the expected request' do
      stager_client.stage('guid', staging_request)
      expect(WebMock).to have_requested(:post, "#{eirini_url}/stage/guid").with(body: {
        app_id: 'thor',
        file_descriptors: 2,
        memory_mb: 420,
        disk_mb: 42,
        environment: [{ 'name' => 'eirini', 'value' => 'some' }],
        timeout: 10,
        log_guid: 'is the actual app id',
        lifecycle: 'example-lifecycle',
        completion_callback: 'completed',
        lifecycle_data: { 'download-url' => 'soundcloud.com' },
        egress_rules: ['rule-1', 'rule-2'],
        isolation_segment: 'isolation'
      }.to_json
      )
    end
  end

  context 'when the response contains an error' do
    before do
      stub_request(:post, "#{eirini_url}/stage/guid").
        to_return(status: 501, body: { 'error' => 'argh' }.to_json)
    end

    it 'should raise an error' do
      expect { stager_client.stage('guid', staging_request) }.to raise_error(CloudController::Errors::ApiError)
    end
  end

  def staging_request
    staging_request = VCAP::CloudController::Diego::StagingRequest.new
    staging_request.app_id              = 'thor'
    staging_request.log_guid            = 'is the actual app id'
    staging_request.file_descriptors = 2
    staging_request.memory_mb            = 420
    staging_request.disk_mb              = 42
    staging_request.environment          = [{ 'name' => 'eirini', 'value' => 'some' }]
    staging_request.timeout = 10
    staging_request.lifecycle = 'example-lifecycle'
    staging_request.lifecycle_data = { 'download-url' => 'soundcloud.com' }
    staging_request.completion_callback = 'completed'
    staging_request.egress_rules = ['rule-1', 'rule-2']
    staging_request.isolation_segment = 'isolation'
    staging_request
  end
end
