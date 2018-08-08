require 'spec_helper'
require 'cloud_controller/deployment_updater/scheduler'

module VCAP::CloudController
  RSpec.describe DeploymentUpdater::Scheduler do
    let(:update_frequency) { 42 }
    before do
      TestConfig.context = :deployment_updater
      TestConfig.override(
        deployment_updater: {
          update_frequency_in_seconds: update_frequency,
        }
      )
    end

    describe '#start' do
      let(:lock_runner) { instance_double(Locket::LockRunner, start: nil, lock_acquired?: nil) }
      let(:lock_worker) { instance_double(Locket::LockWorker) }
      let(:logger) { instance_double(Steno::Logger, info: nil, debug: nil) }
      let(:statsd_client) { instance_double(Statsd) }

      before do
        allow(Locket::LockRunner).to receive(:new).and_return(lock_runner)
        allow(Locket::LockWorker).to receive(:new).and_return(lock_worker)
        allow(Steno).to receive(:logger).and_return(logger)

        allow(lock_worker).to receive(:acquire_lock_and).and_yield
        allow(DeploymentUpdater::Scheduler).to receive(:sleep)
        allow(DeploymentUpdater::Updater).to receive(:update)
        allow(CloudController::DependencyLocator.instance).to receive(:statsd_client).and_return(statsd_client)
        allow(statsd_client).to receive(:time).and_yield
      end

      it 'correctly configures a LockRunner and uses it to initialize a LockWorker' do
        DeploymentUpdater::Scheduler.start

        expect(Locket::LockRunner).to have_received(:new).with(
          key: TestConfig.config_instance.get(:deployment_updater, :lock_key),
          owner: TestConfig.config_instance.get(:deployment_updater, :lock_owner),
          host: TestConfig.config_instance.get(:locket, :host),
          port: TestConfig.config_instance.get(:locket, :port),
          client_ca_path: TestConfig.config_instance.get(:locket, :ca_file),
          client_key_path: TestConfig.config_instance.get(:locket, :key_file),
          client_cert_path: TestConfig.config_instance.get(:locket, :cert_file),
        )

        expect(Locket::LockWorker).to have_received(:new).with(lock_runner)
      end

      it 'runs the DeploymentUpdater::Updater sleeps for the configured frequency' do
        update_duration = 5
        Timecop.freeze do
          allow(DeploymentUpdater::Updater).to receive(:update) do
            Timecop.travel(update_duration)
            true
          end

          DeploymentUpdater::Scheduler.start

          expect(logger).to have_received(:info).with(start_with('Update loop took'))
          expect(DeploymentUpdater::Scheduler).to have_received(:sleep).
            with(be_within(0.01).of(update_frequency - update_duration))
          expect(logger).to have_received(:info).with(start_with('Sleeping'))
        end
      end

      it 'should not sleep if updater takes longer than the configure frequency' do
        update_duration = update_frequency + 1
        Timecop.freeze do
          allow(DeploymentUpdater::Updater).to receive(:update) do
            Timecop.travel(update_duration)
            true
          end

          DeploymentUpdater::Scheduler.start

          expect(logger).to have_received(:info).with(start_with('Update loop took'))
          expect(DeploymentUpdater::Scheduler).not_to have_received(:sleep)
          expect(logger).to have_received(:info).with('Not Sleeping')
        end
      end

      describe 'statsd metrics' do
        it 'records the deployment update duration' do
          timed_block = nil

          allow(statsd_client).to receive(:time) do |_, &block|
            timed_block = block
          end

          DeploymentUpdater::Scheduler.start
          expect(statsd_client).to have_received(:time).with('cc.deployments.update.duration')

          expect(DeploymentUpdater::Updater).to_not have_received(:update)
          timed_block.call
          expect(DeploymentUpdater::Updater).to have_received(:update)
        end
      end
    end
  end
end
