require 'spec_helper'

RSpec.describe 'AppConfiguration' do
  let(:user) { VCAP::CloudController::User.make }
  let(:user_header) { headers_for(user, email: user_email, user_name: user_name) }
  let(:space) { VCAP::CloudController::Space.make }
  let(:user_email) { Sham.email }
  let(:user_name) { 'some-username' }
  let!(:stack) { VCAP::CloudController::Stack.make(name: 'my-sweet-stack') }

  describe 'GET /v3/apps/:guid/configuration' do
    it 'returns the current configuration as JSON' do
      app_model = VCAP::CloudController::AppModel.make(name: 'dora')


      process = VCAP::CloudController::ProcessModel.make(
        app: app_model,
        memory: 256,
        instances: 3,
        disk_quota: 1024,
      )
      process.update(stack: stack)

      domain = VCAP::CloudController::SharedDomain.make(name: 'example.com')
      route = VCAP::CloudController::Route.make(host: 'awesome-host', domain: domain)

      VCAP::CloudController::RouteMappingModel.make(
        app: app_model,
        route: route
      )

      expected_response = {
        'applications' => [
          {
            'name' => 'dora',
            'disk_quota' => 1024,
            'instances' => 3,
            'memory' => 256,
            'routes' => [
              {
                'route' => 'awesome-host.example.com'
              }
            ],
            'stack' => 'my-sweet-stack'
          }
        ]
      }

      get "/v3/apps/#{app_model.guid}/configuration", {}, user_header

      expect(parsed_response).to be_a_response_like(expected_response)
    end
  end

  describe 'PUT /v3/apps/:guid/configuration' do
    let(:app_model) {VCAP::CloudController::AppModel.make(name: 'dora')}

    before do
      # preconditions
      VCAP::CloudController::PackageModel.make(:ready, app: app_model)

      # build
      allow_any_instance_of(CloudController::Blobstore::UrlGenerator).to receive(:v3_app_buildpack_cache_download_url).and_return('some-string')
      allow_any_instance_of(CloudController::Blobstore::UrlGenerator).to receive(:v3_app_buildpack_cache_upload_url).and_return('some-string')
      allow_any_instance_of(CloudController::Blobstore::UrlGenerator).to receive(:package_download_url).and_return('some-string')
      allow_any_instance_of(CloudController::Blobstore::UrlGenerator).to receive(:package_droplet_upload_url).and_return('some-string')
      stub_request(:put, %r{#{TestConfig.config[:diego][:stager_url]}/v1/staging/}).
        to_return(status: 202, body: {
          execution_metadata: 'String',
          detected_start_command: {},
          lifecycle_data: {
            buildpack_key: 'String',
            detected_buildpack: 'String',
          }
        }.to_json)
    end

    context 'when there is an app that is already staged' do
      before do
        VCAP::CloudController::ProcessModel.make(app: app_model, type: 'web', disk_quota: 2048, instances: 1, memory: 128)
      end

      it 'configures the app to match the configuration' do
        push_request = {
          'applications' => [
            {
              'name' => 'dora',
              'disk_quota' => 1024,
              'instances' => 3,
              'memory' => 256,
              'stack' => 'my-sweet-stack'
            }
          ]
        }

        put "/v3/apps/#{app_model.guid}/configuration", push_request.to_json, user_header
        expect(last_response.status).to eq(200)

        process = app_model.reload.processes.first
        expect(app_model.name).to eq 'dora'
        expect(process.disk_quota).to eq 1024
        expect(process.instances).to eq 3
        expect(process.memory).to eq 256

        expect(process.stack.name).to eq 'my-sweet-stack'
      end
    end

    context 'when there is an unstaged app' do
      it 'configures the app to match the configuration' do
        rake_process = VCAP::CloudController::ProcessModel.make(app: app_model, type: 'rake')
        push_request = {
          "applications": [
            {
              "name": app_model.name,
              "processes": [
                {
                  "type": "web",
                  "disk_quota": 1,
                  "instances": 5,
                  "memory": 10,
                  "command": "rackup"
                },
                {
                  "type": "rake",
                  "disk_quota": 1500,
                  "instances": 0,
                  "memory": 1000,
                }
              ]
            }
          ]
        }
1+1
        put "/v3/apps/#{app_model.guid}/configuration", push_request.to_json, user_header
        expect(last_response.status).to eq(200)

        process1 = app_model.reload.processes.find { |p| p.type == 'web' }
        process2 = rake_process.reload

        expect(app_model.name).to eq 'dora'
        expect(process1.type).to eq 'web'
        expect(process1.disk_quota).to eq 1
        expect(process1.instances).to eq 5
        expect(process1.memory).to eq 10

        expect(process2.type).to eq 'rake'
        expect(process2.disk_quota).to eq 1500
        expect(process2.instances).to eq 0
        expect(process2.memory).to eq 1000
      end
    end

    xit 'can configure an app with routes' do
      request = {

        'applications' => [
          {
            'name' => 'dora',
            'routes' => [
              {
                'route' => 'awesome-host.example.com'
              }
            ]
          }
        ]
      }

      expect(app.routes.first.uri).to eq 'awesome-host.example.com'
    end
  end
end
