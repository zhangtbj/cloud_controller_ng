module VCAP::CloudController
  class RouteCreate
    def initialize(access_validator:, logger:)
      @access_validator = access_validator
      @logger = logger
    end

    def create_route(route_hash:, generate_port: false, router_group: nil)
      Route.db.transaction do

        if generate_port
          Locking[name: 'random-ports'].lock!
          generated_port = PortGenerator.new(route_hash['domain_guid']).generate_port(router_group.reservable_ports)
          raise CloudController::Errors::ApiError.new_from_details('OutOfRouterGroupPorts', router_group) if generated_port < 0
          route_hash['port'] = generated_port
        end

        route = Route.create_from_hash(route_hash)
        @access_validator.validate_access(:create, route)

        begin
          CopilotAdapter.create_route(route) if Config.config.get(:copilot, :enabled)
        rescue CopilotAdapter::CopilotUnavailable => e
          @logger.error("failed communicating with copilot backend: #{e.message}")
        end

        route
      end
    end
  end
end
