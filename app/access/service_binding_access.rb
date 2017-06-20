module VCAP::CloudController
  class ServiceBindingAccess < BaseAccess
    def create?(service_binding, params=nil)
      raise 'callers should use Membership to determine this'
    end

    def delete?(service_binding)
      raise 'callers should use Membership to determine this'
    end

    def read_env?(service_binding)
      return true if admin_user? || admin_read_only_user?
      authz.can_do?(
        "urn:app:/#{service_binding.app.space.organization.guid}/#{service_binding.app.space.guid}/#{service_binding.app.guid}",
        'see-secrets',
        SecurityContext.current_user_id
      )
    end

    def read_env_with_token?(service_binding)
      read_with_token?(service_binding)
    end

    private

    def acl_client
      @acl_client ||= VCAP::CloudController::AclServiceClient.new
    end

    def authz
      @authz ||= VCAP::CloudController::Authz.new(acl_client)
    end
  end
end
