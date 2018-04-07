require 'cloud_controller/app_manifest/route_domain_splitter'

module VCAP::CloudController
  class RouteUpdate
    class InvalidProcess < StandardError; end

    def initialize(user_audit_info)
      @user_audit_info = user_audit_info
    end

    def update(route_hash, message)
      Route.db.transaction do
        route = Route.create_from_hash(route_hash)
        if message.requested?(:routes)

        end
        route.save

        Repositories::RouteEventRepository.record_update(route_hash, @user_audit_info, message.audit_hash)
      end
    rescue Sequel::ValidationFailed => e
      raise RouteInvalid.new(e.message)
    end
  end
end
