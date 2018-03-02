require 'actions/current_process_types'

module VCAP::CloudController
  class AppRestart
    class Error < StandardError
    end

    class << self
      def restart(app:, config:, user_audit_info:)
        # need_to_stop_in_runtime = !app.stopped?

        app.db.transaction do
          app.lock!
          app.update(desired_state: ProcessModel::STARTED)
          app.processes.each do |process|
            process.skip_process_observer_on_update = true

            # A side-effect of submitting LRP requests before the transaction commits is that
            # the annotation timestamp stored on the LRP is slightly different than the process.updated_at
            # timestamp that is stored in the DB due to timestamp precision differences.
            # This difference causes the sync job to submit an extra update LRP request which updates
            # the LRP annotation at a later time. This should have no impact on the running LRP.

            # if need_to_stop_in_runtime
            #   process.update(state: ProcessModel::STOPPED)
            #   runners(config).runner_for_process(process).stop
            # end

            process.update(state: ProcessModel::STARTED)

            cloned_process = VCAP::CloudController::ProcessCloner.clone_record(process)

            runners(config).runner_for_process(process).start
            runners(config).runner_for_process(cloned_process).start
          end
          record_audit_event(app, user_audit_info)
        end
      rescue Sequel::ValidationFailed => e
        raise Error.new(e.message)
      end

      private

      def runners(config)
        Runners.new(config)
      end

      def record_audit_event(app, user_audit_info)
        Repositories::AppEventRepository.new.record_app_restart(
          app,
          user_audit_info,
        )
      end
    end
  end

  class ProcessCloner
    def self.clone_record(record)
      clone_hash = {}

      record.values.each do |k, v|
        if k == :id
          next
        # process types have a uniqueness constraint
        elsif k == :type
          clone_hash[:type] = "clone-#{v}"
        end
        clone_hash[k] = v
      end

      ProcessModel.new(clone_hash).save
    end
  end
end
