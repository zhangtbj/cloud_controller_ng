module VCAP::CloudController
  class ServiceKeyAccess < BaseAccess
    def create?(service_key, params=nil)
      return true if admin_user?
      return false if service_key.in_suspended_org?
      service_key.service_instance.space.has_developer?(context.user)
    end

    def delete?(service_key)
      create?(service_key)
    end

    def read?(service_key)
      context.can_see_secrets_in_space?(service_key.service_instance.space)
    end

    def read_env?(service_key)
      context.can_see_secrets_in_space?(service_key.space)
    end

    def read_env_with_token?(service_key)
      read_with_token?(service_key)
    end

    def index?(_, params=nil)
      return true if context.can_see_secrets_globally?
      return true unless params && params.key?(:related_obj)
      context.can_see_secrets_in_space?(params[:related_obj].space)
    end
  end
end
