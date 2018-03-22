require 'cf-copilot'

module VCAP::CloudController
  class CopilotHandler
    class CopilotUnavailable < StandardError; end

    def create_route(route)
      copilot_client.upsert_route(
        guid: route.guid,
        host: route.fqdn
      )
    rescue StandardError => e
      raise CopilotUnavailable.new(e.message)
    end

    def associate_processes(capi_process_guid, diego_process_guid)
      logger.info("Fake associating CAPI process #{capi_process_guid} with Diego process #{diego_process_guid}")
      # copilot_client.associate_processes(
      #     capi_process_guid: capi_process_guid,
      #     diego_process_guid: diego_process_guid
      # )
    end

    def map_route(route_mapping)
      logger.info("Mapping route for route #{route_mapping.route.guid} and CAPI process #{route_mapping.process.guid}")
      copilot_client.map_route(
        capi_process_guid: route_mapping.process.guid,
        diego_process_guid: Diego::ProcessGuid.from_process(route_mapping.process),
        route_guid: route_mapping.route.guid
      )
    rescue StandardError => e
      raise CopilotUnavailable.new(e.message)
    end

    def unmap_route(route_mapping)
      logger.info("Unmapping route for route #{route_mapping.route.guid} and CAPI process #{route_mapping.process.guid}")
      copilot_client.unmap_route(
        capi_process_guid: route_mapping.process.guid,
        route_guid: route_mapping.route.guid
      )
    rescue StandardError => e
      raise CopilotUnavailable.new(e.message)
    end

    private

    def logger
      @logger ||= Steno.logger('copilot_handler')
    end

    def copilot_client
      @copilot_client ||= CloudController::DependencyLocator.instance.copilot_client
    end
  end
end
