module VCAP
  module CloudController
    module Perm
      class Permissions
        ORG_MANAGER_PERMISSION = 'org.manager'.freeze
        ORG_AUDITOR_PERMISSION = 'org.auditor'.freeze
        ORG_BILLING_MANAGER_PERMISSION = 'org.billing_manager'.freeze
        ORG_USER_PERMISSION = 'org.user'.freeze

        SPACE_MANAGER_PERMISSION = 'space.manager'.freeze
        SPACE_DEVELOPER_PERMISSION = 'space.developer'.freeze
        SPACE_AUDITOR_PERMISSION = 'space.auditor'.freeze

        def initialize(perm_client:, user_id:, issuer:, roles:)
          @perm_client = perm_client
          @user_id = user_id
          @roles = roles
          @issuer = issuer
        end

        # Taken from lib/cloud_controller/permissions.rb
        def can_read_globally?
          roles.admin? || roles.admin_read_only? || roles.global_auditor?
        end

        # Taken from lib/cloud_controller/permissions.rb
        def can_read_secrets_globally?
          roles.admin? || roles.admin_read_only?
        end

        # Taken from lib/cloud_controller/permissions.rb
        def can_write_globally?
          roles.admin?
        end

        def can_read_from_org?(org_id)
          permissions = [
            { permission_name: ORG_MANAGER_PERMISSION, resource_id: org_id },
            { permission_name: ORG_AUDITOR_PERMISSION, resource_id: org_id },
            { permission_name: ORG_USER_PERMISSION, resource_id: org_id },
            { permission_name: ORG_BILLING_MANAGER_PERMISSION, resource_id: org_id },
          ]
          can_read_globally? || has_any_permission?(permissions)
        end

        def can_write_to_org?(org_id)
          permissions = [
            { permission_name: ORG_MANAGER_PERMISSION, resource_id: org_id },
          ]

          can_write_globally? || has_any_permission?(permissions)
        end

        def can_read_from_space?(space_id, org_id)
          permissions = [
            { permission_name: SPACE_DEVELOPER_PERMISSION, resource_id: space_id },
            { permission_name: SPACE_MANAGER_PERMISSION, resource_id: space_id },
            { permission_name: SPACE_AUDITOR_PERMISSION, resource_id: space_id },
            { permission_name: ORG_MANAGER_PERMISSION, resource_id: org_id },
          ]

          can_read_globally? || has_any_permission?(permissions)
        end

        def can_see_secrets_in_space?(space_id, _)
          permissions = [
            { permission_name: SPACE_DEVELOPER_PERMISSION, resource_id: space_id },
          ]

          can_read_secrets_globally? || has_any_permission?(permissions)
        end

        def can_write_to_space?(space_id)
          permissions = [
            { permission_name: SPACE_DEVELOPER_PERMISSION, resource_id: space_id },
          ]

          can_write_globally? || has_any_permission?(permissions)
        end

        def can_read_from_isolation_segment?(isolation_segment)
          can_read_globally? ||
            isolation_segment.spaces.any? { |space| can_read_from_space?(space.guid, space.organization.guid) } ||
            isolation_segment.organizations.any? { |org| can_read_from_org?(org.guid) }
        end

        def readable_space_guids
          readable_space_guids_from_org_roles.concat(readable_space_guids_from_space_roles)
        end

        private

        attr_reader :perm_client, :user_id, :roles, :issuer

        def has_any_permission?(permissions)
          perm_client.has_any_permission?(permissions: permissions, user_id: user_id, issuer: issuer)
        end

        def readable_space_guids_from_org_roles
          org_guids = perm_client.list_resource_patterns(
            user_id: user_id,
            issuer: issuer,
            permissions: [ORG_MANAGER_PERMISSION]
          )
          org_ids = Organization.select(:id).
            where(guid: org_guids).
            all.
            reject(&:nil?).
            map(&:id)

          Space.select(:guid).
            where(organization_id: org_ids).
            reject(&:nil?).
            map(&:guid)
        end

        def readable_space_guids_from_space_roles
          perm_client.list_resource_patterns(
            user_id: user_id,
            issuer: issuer,
            permissions: [
              SPACE_DEVELOPER_PERMISSION,
              SPACE_MANAGER_PERMISSION,
              SPACE_AUDITOR_PERMISSION,
              ORG_MANAGER_PERMISSION
            ]
          )
        end
      end
    end
  end
end
