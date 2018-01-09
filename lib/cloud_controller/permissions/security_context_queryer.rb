module VCAP::CloudController
  class Permissions::SecurityContextQueryer
    def can_read_globally?
      security_context.admin? || security_context.admin_read_only? || security_context.global_auditor?
    end

    def can_see_secrets_globally?
      security_context.admin? || security_context.admin_read_only?
    end

    def can_write_globally?
      security_context.admin?
    end

    def can_read_from_org?(org)
      can_read_globally? || org.managers.include?(user) || org.billing_managers.include?(user) ||
        org.auditors.include?(user) || org.users.include?(user)
    end

    def can_write_to_org?(org)
      can_write_globally? || org.managers.include?(user)
    end

    def can_read_from_space?(space, org)
      can_read_globally? || space.has_member?(user) || org.managers.include?(user)
    end

    def can_see_secrets_in_space?(space)
      can_see_secrets_globally? || space.has_developer?(user)
    end

    def can_write_to_space?(space)
      can_write_globally? || space.has_developer?(user)
    end

    private

    def security_context
      VCAP::CloudController::SecurityContext
    end

    def user
      @current_user ||= security_context.current_user
      @current_user
    end
  end
end
