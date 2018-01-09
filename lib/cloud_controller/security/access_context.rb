module VCAP::CloudController
  module Security
    class AccessContext
      include ::Allowy::Context

      def initialize(permission_queryer)
        super()
        @permission_queryer = permission_queryer
      end

      def admin_override
        VCAP::CloudController::SecurityContext.admin? || VCAP::CloudController::SecurityContext.admin_read_only? || VCAP::CloudController::SecurityContext.global_auditor?
      end

      def roles
        VCAP::CloudController::SecurityContext.roles
      end

      def user_email
        VCAP::CloudController::SecurityContext.current_user_email
      end

      def user
        VCAP::CloudController::SecurityContext.current_user
      end

      def can_read_resources?
        permission_queryer.can_read_resources?
      end

      def can_write_resources?
        permission_queryer.can_write_resources?
      end

      def can_read_globally?
        permission_queryer.can_read_globally?
      end

      def can_see_secrets_globally?
        permission_queryer.can_see_secrets_globally?
      end

      def can_write_globally?
        permission_queryer.can_write_globally?
      end

      def can_read_from_org?(org)
        !org.nil? && permission_queryer.can_read_from_org?(org)
      end

      def can_write_to_org?(org)
        !org.nil? && permission_queryer.can_write_to_org?(org)
      end

      def can_read_from_space?(space, org)
        !space.nil? && !org.nil? && permission_queryer.can_read_from_space?(space, org)
      end

      def can_see_secrets_in_space?(space)
        !space.nil? && permission_queryer.can_see_secrets_in_space?(space)
      end

      def can_write_to_space?(space)
        !space.nil? && permission_queryer.can_write_to_space?(space)
      end

      private

      attr_reader :permission_queryer
    end
  end
end
