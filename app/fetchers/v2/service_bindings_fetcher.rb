module VCAP::CloudController
  class ServiceBindingsFetcher
    def fetch(user_id, admin_override)
      if admin_override
        fetch_full_dataset
      elsif user_id
        fetch_user_visible_dataset(user_id)
      else
        fetch_unauthenticated_dataset
      end
    end

    private

    def fetch_full_dataset
      ServiceBinding.dataset
    end

    def fetch_user_visible_dataset(user_id)
      urns = authz.get_acl('app', 'read', user_id)

      return fetch_unauthenticated_dataset if urns.empty?

      dataset = ServiceBinding.dataset
      filters = []
      urns.each do |urn|
        _, _, path = urn.split(':')
        _, org_guid, space_guid, app_guid = path.split('/')

        if app_guid && app_guid != '*'
          filters << [:service_bindings__app_guid, app_guid]
        else
          if space_guid && space_guid != '*'
            filters << [:service_bindings__app_guid, AppModel.where(space_guid: space_guid).select(:guid)]
          else
            if org_guid && org_guid != '*'
              filters << [:service_bindings__app_guid, AppModel.where(space_guid: Organization.where(guid: org_guid).map(&:spaces).flatten.map(&:guid)).select(:guid)]
            end
          end
        end
      end

      filters.empty? ? dataset : dataset.where(Sequel.or(filters))
    end

    def fetch_unauthenticated_dataset
      ServiceBinding.dataset.nullify
    end

    def acl_client
      @acl_client ||= VCAP::CloudController::AclServiceClient.new
    end

    def authz
      @authz ||= VCAP::CloudController::Authz.new(acl_client)
    end
  end
end
