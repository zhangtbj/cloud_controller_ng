module VCAP::CloudController
  class ServiceBindingAccess < BaseAccess
    def create?(service_binding, params=nil)
      raise 'callers should use Membership to determine this'
    end

    def delete?(service_binding)
      raise 'callers should use Membership to determine this'
    end

    def read_env?(service_binding)
      context.can_see_secrets_in_space?(service_binding.space)
    end

    def read_env_with_token?(service_binding)
      read_with_token?(service_binding)
    end
  end
end
