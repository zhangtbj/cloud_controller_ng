require 'actions/current_process_types'

module VCAP::CloudController
  class AppStart
    class InvalidApp < StandardError; end

    class << self
      def start(app:, user_audit_info:, record_event: true)
        app.db.transaction do
          app.lock!
          app.update(desired_state: ProcessModel::STARTED)
          app.processes.each { |process| process.update(state: ProcessModel::STARTED) }

          record_audit_event(app, user_audit_info) if record_event
        end
      rescue Sequel::ValidationFailed => e
        raise InvalidApp.new(e.message)
      end

      def start_next_droplet(app:, user_audit_info:, record_event: true)
        # TODO: how?
        # app.processes.add(make_new_process_from_next_droplet)
        # app.all_those_proceses = started state

        app.db.transaction do
          app.lock!
          app.processes.each do |process|
            db_process = VCAP::CloudController::ProcessFetcher.new.fetch(process_guid: process.guid).first

            cloned_process = VCAP::CloudController::ProcessCloner.clone_record(db_process)
            cloned_process.update(state: ProcessModel::STARTED, current_droplet: app.next_droplet)

            diego_runner = CloudController::DependencyLocator.instance.runners.runner_for_process(cloned_process)
            diego_runner.start
          end
        end
      rescue Sequel::ValidationFailed => e
        raise InvalidApp.new(e.message)
      end

      def start_without_event(app)
        start(app: app, user_audit_info: nil, record_event: false)
      end

      private

      def record_audit_event(app, user_audit_info)
        Repositories::AppEventRepository.new.record_app_start(
          app,
          user_audit_info,
        )
      end
    end
  end
end
