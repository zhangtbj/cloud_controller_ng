require 'spec_helper'

$LOAD_PATH.unshift('app')

require 'cloud_controller/opi/apps_client'

# This spec requires the OPI binary to be in $PATH
skip_opi_tests = ENV['CF_RUN_OPI_SPECS'] != 'true'
RSpec.describe(OPI::Client, opi: skip_opi_tests) do
  let(:opi_url) { 'http://localhost:8085' }
  subject(:client) { described_class.new(opi_url) }
  let(:process) { double(guid: 'jeff',
                         desired_instances: 5,
                         updated_at: '1241232.42')
  }

  before :all do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  def up?(url)
    HTTPClient.new.get(url)
  rescue Errno::ECONNREFUSED
    yield if block_given?
    nil
  end

  before do
    @pid = Process.spawn('opi simulator')

    raise 'Boom' unless 5.times.any? { up?(opi_url) {
      sleep 0.1
    }}
  end

  after do
    Process.kill('SIGTERM', @pid)
  end

  context 'OPI system tests' do
    context 'Desire an app' do
      let(:cfg) { ::VCAP::CloudController::Config.new({ default_health_check_timeout: 99 }) }
      let(:lifecycle_type) { nil }
      let(:app_model) {
        ::VCAP::CloudController::AppModel.make(lifecycle_type,
                                               guid: 'app-guid',
                                               droplet: ::VCAP::CloudController::DropletModel.make(state: 'STAGED'),
                                               enable_ssh: false,
                                               environment_variables: { 'BISH': 'BASH', 'FOO': 'BAR' })
      }

      let(:lrp) do
        lrp = ::VCAP::CloudController::ProcessModel.make(:process,
          app:                  app_model,
          state:                'STARTED',
          diego:                false,
          guid:                 'process-guid',
          type:                 'web',
          health_check_timeout: 12,
          instances:            21,
          memory:               128,
          disk_quota:           256,
          command:              'ls -la',
          file_descriptors:     32,
          health_check_type:    'port',
          enable_ssh:           false,
        )
        lrp.this.update(updated_at: Time.at(2))
        lrp.reload
      end

      it 'does not error' do
        expect { client.desire_app(lrp) }.to_not raise_error
      end
    end

    context 'Get an app' do
      it 'does not error' do
        WebMock.allow_net_connect!
        expect { client.get_app(process) }.to_not raise_error
      end

      it 'returns the correct process' do
        actual_process = client.get_app(process)
        expect(actual_process.process_guid).to eq('jeff')
      end
    end

    context 'Update an app' do
      before do
        routes = {
              'http_routes' => [
                {
                  'hostname'          => 'numero-uno.example.com',
                  'port'              => 8080
                },
                {
                  'hostname'          => 'numero-dos.example.com',
                  'port'              => 8080
                }
              ]
        }

        routing_info = instance_double(VCAP::CloudController::Diego::Protocol::RoutingInfo)
        allow(routing_info).to receive(:routing_info).and_return(routes)
        allow(VCAP::CloudController::Diego::Protocol::RoutingInfo).to receive(:new).with(process).and_return(routing_info)
      end

      it 'does not error' do
        WebMock.allow_net_connect!
        expect { client.update_app(process, {}) }.to_not raise_error
      end
    end
  end
end
