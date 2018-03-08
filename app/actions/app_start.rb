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
        original_processes = []
        cloned_processes = {}
        app.db.transaction do
          app.lock!
          original_processes = app.processes
          app.processes.each do |process|
            process.reload

            route_mapping = RouteMappingModel.where(app: app, process_type: process.type).first

            cloned_process = VCAP::CloudController::ProcessCloner.clone_record(process)

            if route_mapping.present?
              VCAP::CloudController::RouteMappingCloner.clone_record(route_mapping, cloned_process)
            end

            cloned_process.update(state: ProcessModel::STARTED, current_droplet: app.next_droplet)

            diego_runner = CloudController::DependencyLocator.instance.runners.runner_for_process(cloned_process)
            diego_runner.start
            cloned_processes[process.type] = cloned_process
          end
        end

        # Poll desired cloned processes until they're RUNNING
        desired_cloned_process = cloned_processes.values.select { |p| p.instances > 0 }
        all_cloned_processes_running = poll_process_status(desired_cloned_process)

        if all_cloned_processes_running
          app.db.transaction do
            app.lock!
            # Delete original processes so we can reuse their types
            original_processes.map(&:destroy)

            cloned_processes.each do |type, process|
              # Update cloned processes to their original types
              clone_type = process.type
              process.type = type
              process.save

              # Delete route mapping pointing to "clone-*" processes
              RouteMappingDelete.new(user_audit_info).delete(
                RouteMappingModel.where(app: app, process_type: clone_type).first
              )
            end
          end
        else
          app.db.transaction do
            app.lock!
            cloned_processes.each do |type, process|
              # Delete route mapping pointing to "clone-*" processes
              RouteMappingDelete.new(user_audit_info).delete(
                RouteMappingModel.where(app: app, process_type: process.type).first
              )

              # Delete cloned processes so the zdt can be reattempted
              process.destroy
            end
          end
          raise CloudController::Errors::ApiError.new_from_details('UnableToPerform', 'Zero Downtime Deploy', 'new processes failed to start')
        end

      rescue Sequel::ValidationFailed => e
        raise InvalidApp.new(e.message)
      end

      def poll_process_status(processes)
        30.times do
          sleep 1
          return true if processes.all? { |process| process_is_running?(process) }
        end

        return false
      end

      def start_without_event(app)
        start(app: app, user_audit_info: nil, record_event: false)
      end

      private

      def process_is_running?(process)
        stats = instances_reporter.stats_for_app(process)
        stats[0][:state] == 'RUNNING'
      end

      def instances_reporter
        CloudController::DependencyLocator.instance.instances_reporters
      end

      def record_audit_event(app, user_audit_info)
        Repositories::AppEventRepository.new.record_app_start(
          app,
          user_audit_info,
        )
      end
    end
  end
end
