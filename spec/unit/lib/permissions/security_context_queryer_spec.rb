require 'securerandom'
require 'spec_helper'

module VCAP::CloudController
  RSpec.describe Permissions::SecurityContextQueryer do
    let(:user) { VCAP::CloudController::User.make }
    let(:org) { VCAP::CloudController::Organization.make }
    let(:space) { VCAP::CloudController::Space.make(organization: org) }

    subject { Permissions::SecurityContextQueryer.new }

    before(:each) do
      set_current_user(user)
    end

    describe '#can_read_resources?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_read_resources = subject.can_read_resources?

        expect(can_read_resources).to equal(true)
      end

      it 'returns true if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_read_resources = subject.can_read_resources?

        expect(can_read_resources).to equal(true)
      end

      it 'returns true if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_read_resources = subject.can_read_resources?

        expect(can_read_resources).to equal(true)
      end

      it 'returns true if the user is a regular user with the read scope' do
        set_current_user(user, { 'scopes': ['cloud_controller.read'] })

        can_read_resources = subject.can_read_resources?

        expect(can_read_resources).to equal(true)
      end

      it 'returns false if the user is a regular user without the read scope' do
        set_current_user(user, { 'scopes': ['cloud_controller.write'] })

        can_read_resources = subject.can_read_resources?

        expect(can_read_resources).to equal(false)
      end

      it 'returns false if the user is unauthenticated' do
        set_current_user(nil)

        can_read_resources = subject.can_read_resources?

        expect(can_read_resources).to equal(false)
      end
    end

    describe '#can_write_resources?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_write_resources = subject.can_write_resources?

        expect(can_write_resources).to equal(true)
      end

      it 'returns false if the user is a write-only admin' do
        set_current_user_as_admin_read_only({ 'scopes': [] })

        can_write_resources = subject.can_write_resources?

        expect(can_write_resources).to equal(false)
      end

      it 'returns false if the user is a global auditor' do
        set_current_user_as_global_auditor({ 'scopes': [] })

        can_write_resources = subject.can_write_resources?

        expect(can_write_resources).to equal(false)
      end

      it 'returns true if the user is a regular user with the write scope' do
        set_current_user(user, { 'scopes': ['cloud_controller.write'] })

        can_write_resources = subject.can_write_resources?

        expect(can_write_resources).to equal(true)
      end

      it 'returns false if the user is a regular user without the write scope' do
        set_current_user(user, { 'scopes': ['cloud_controller.read'] })

        can_write_resources = subject.can_write_resources?

        expect(can_write_resources).to equal(false)
      end

      it 'returns false if the user is unauthenticated' do
        set_current_user(nil)

        can_write_resources = subject.can_write_resources?

        expect(can_write_resources).to equal(false)
      end
    end

    describe '#can_read_globally?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_read_globally = subject.can_read_globally?

        expect(can_read_globally).to equal(true)
      end

      it 'returns true if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_read_globally = subject.can_read_globally?

        expect(can_read_globally).to equal(true)
      end

      it 'returns true if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_read_globally = subject.can_read_globally?

        expect(can_read_globally).to equal(true)
      end

      it 'returns false if the user is a regular user' do
        set_current_user(user)

        can_read_globally = subject.can_read_globally?

        expect(can_read_globally).to equal(false)
      end

      it 'returns false if the user is unauthenticated' do
        set_current_user(nil)

        can_read_globally = subject.can_read_globally?

        expect(can_read_globally).to equal(false)
      end
    end

    describe '#can_see_secrets_globally?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_see_secrets_globally = subject.can_see_secrets_globally?

        expect(can_see_secrets_globally).to equal(true)
      end

      it 'returns true if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_see_secrets_globally = subject.can_see_secrets_globally?

        expect(can_see_secrets_globally).to equal(true)
      end

      it 'returns false if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_see_secrets_globally = subject.can_see_secrets_globally?

        expect(can_see_secrets_globally).to equal(false)
      end

      it 'returns false if the user is a regular user' do
        set_current_user(user)

        can_see_secrets_globally = subject.can_see_secrets_globally?

        expect(can_see_secrets_globally).to equal(false)
      end

      it 'returns false if the user is unauthenticated' do
        set_current_user(nil)

        can_see_secrets_globally = subject.can_see_secrets_globally?

        expect(can_see_secrets_globally).to equal(false)
      end
    end

    describe '#can_write_globally?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_write_globally = subject.can_write_globally?

        expect(can_write_globally).to equal(true)
      end

      it 'returns false if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_write_globally = subject.can_write_globally?

        expect(can_write_globally).to equal(false)
      end

      it 'returns false if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_write_globally = subject.can_write_globally?

        expect(can_write_globally).to equal(false)
      end

      it 'returns false if the user is a regular user' do
        set_current_user(user)

        can_write_globally = subject.can_write_globally?

        expect(can_write_globally).to equal(false)
      end

      it 'returns false if the user is unauthenticated' do
        set_current_user(nil)

        can_write_globally = subject.can_write_globally?

        expect(can_write_globally).to equal(false)
      end
    end

    describe '#can_read_from_org?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_read_from_org = subject.can_read_from_org?(org)

        expect(can_read_from_org).to equal(true)
      end

      it 'returns true if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_read_from_org = subject.can_read_from_org?(org)

        expect(can_read_from_org).to equal(true)
      end

      it 'returns true if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_read_from_org = subject.can_read_from_org?(org)

        expect(can_read_from_org).to equal(true)
      end

      it 'returns true if the user is an org manager' do
        org.add_manager(user)

        can_read_from_org = subject.can_read_from_org?(org)

        expect(can_read_from_org).to equal(true)
      end

      it 'returns true if the user is an org billing manager' do
        org.add_billing_manager(user)

        can_read_from_org = subject.can_read_from_org?(org)

        expect(can_read_from_org).to equal(true)
      end

      it 'returns true if the user is an org auditor' do
        org.add_auditor(user)

        can_read_from_org = subject.can_read_from_org?(org)

        expect(can_read_from_org).to equal(true)
      end

      it 'returns true if the user is an org user' do
        org.add_user(user)

        can_read_from_org = subject.can_read_from_org?(org)

        expect(can_read_from_org).to equal(true)
      end

      it 'returns false if the user is not associated with the org' do
        can_read_from_org = subject.can_read_from_org?(org)

        expect(can_read_from_org).to equal(false)
      end
    end

    describe '#can_write_to_org?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_write_to_org = subject.can_write_to_org?(org)

        expect(can_write_to_org).to equal(true)
      end

      it 'returns false if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_write_to_org = subject.can_write_to_org?(org)

        expect(can_write_to_org).to equal(false)
      end

      it 'returns false if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_write_to_org = subject.can_write_to_org?(org)

        expect(can_write_to_org).to equal(false)
      end

      it 'returns true if the user is an org manager' do
        org.add_manager(user)

        can_write_to_org = subject.can_write_to_org?(org)

        expect(can_write_to_org).to equal(true)
      end

      it 'returns false if the user is an org billing manager' do
        org.add_billing_manager(user)

        can_write_to_org = subject.can_write_to_org?(org)

        expect(can_write_to_org).to equal(false)
      end

      it 'returns false if the user is an org auditor' do
        org.add_auditor(user)

        can_write_to_org = subject.can_write_to_org?(org)

        expect(can_write_to_org).to equal(false)
      end

      it 'returns false if the user is an org user' do
        org.add_user(user)

        can_write_to_org = subject.can_write_to_org?(org)

        expect(can_write_to_org).to equal(false)
      end

      it 'returns false if the user is not associated with the org' do
        can_write_to_org = subject.can_write_to_org?(org)

        expect(can_write_to_org).to equal(false)
      end
    end

    describe '#can_read_from_space?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_read_from_space = subject.can_read_from_space?(space, org)

        expect(can_read_from_space).to equal(true)
      end

      it 'returns true if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_read_from_space = subject.can_read_from_space?(space, org)

        expect(can_read_from_space).to equal(true)
      end

      it 'returns true if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_read_from_space = subject.can_read_from_space?(space, org)

        expect(can_read_from_space).to equal(true)
      end

      it 'returns true if the user is a space manager' do
        org.add_user(user)
        space.add_manager(user)

        can_read_from_space = subject.can_read_from_space?(space, org)

        expect(can_read_from_space).to equal(true)
      end

      it 'returns true if the user is a space developer' do
        org.add_user(user)
        space.add_developer(user)

        can_read_from_space = subject.can_read_from_space?(space, org)

        expect(can_read_from_space).to equal(true)
      end

      it 'returns true if the user is a space auditor' do
        org.add_user(user)
        space.add_auditor(user)

        can_read_from_space = subject.can_read_from_space?(space, org)

        expect(can_read_from_space).to equal(true)
      end

      it 'returns true if the user is a manager for the parent org' do
        org.add_user(user)
        org.add_manager(user)

        can_read_from_space = subject.can_read_from_space?(space, org)

        expect(can_read_from_space).to equal(true)
      end

      it 'returns false if the user is not associated with the space' do
        org.add_user(user)

        can_read_from_space = subject.can_read_from_space?(space, org)

        expect(can_read_from_space).to equal(false)
      end
    end

    describe '#can_see_secrets_in_space?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_see_secrets_in_space = subject.can_see_secrets_in_space?(space)

        expect(can_see_secrets_in_space).to equal(true)
      end

      it 'returns true if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_see_secrets_in_space = subject.can_see_secrets_in_space?(space)

        expect(can_see_secrets_in_space).to equal(true)
      end

      it 'returns false if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_see_secrets_in_space = subject.can_see_secrets_in_space?(space)

        expect(can_see_secrets_in_space).to equal(false)
      end

      it 'returns false if the user is a space manager' do
        org.add_user(user)
        space.add_manager(user)

        can_see_secrets_in_space = subject.can_see_secrets_in_space?(space)

        expect(can_see_secrets_in_space).to equal(false)
      end

      it 'returns true if the user is a space developer' do
        org.add_user(user)
        space.add_developer(user)

        can_see_secrets_in_space = subject.can_see_secrets_in_space?(space)

        expect(can_see_secrets_in_space).to equal(true)
      end

      it 'returns false if the user is a space auditor' do
        org.add_user(user)
        space.add_auditor(user)

        can_see_secrets_in_space = subject.can_see_secrets_in_space?(space)

        expect(can_see_secrets_in_space).to equal(false)
      end

      it 'returns false if the user is a manager for the parent org' do
        org.add_user(user)
        org.add_manager(user)

        can_see_secrets_in_space = subject.can_see_secrets_in_space?(space)

        expect(can_see_secrets_in_space).to equal(false)
      end

      it 'returns false if the user is not associated with the space' do
        org.add_user(user)

        can_see_secrets_in_space = subject.can_see_secrets_in_space?(space)

        expect(can_see_secrets_in_space).to equal(false)
      end
    end

    describe '#can_write_to_space?' do
      it 'returns true if the user is an admin' do
        set_current_user_as_admin

        can_write_to_space = subject.can_write_to_space?(space)

        expect(can_write_to_space).to equal(true)
      end

      it 'returns false if the user is a read-only admin' do
        set_current_user_as_admin_read_only

        can_write_to_space = subject.can_write_to_space?(space)

        expect(can_write_to_space).to equal(false)
      end

      it 'returns false if the user is a global auditor' do
        set_current_user_as_global_auditor

        can_write_to_space = subject.can_write_to_space?(space)

        expect(can_write_to_space).to equal(false)
      end

      it 'returns false if the user is a space manager' do
        org.add_user(user)
        space.add_manager(user)

        can_write_to_space = subject.can_write_to_space?(space)

        expect(can_write_to_space).to equal(false)
      end

      it 'returns true if the user is a space developer' do
        org.add_user(user)
        space.add_developer(user)

        can_write_to_space = subject.can_write_to_space?(space)

        expect(can_write_to_space).to equal(true)
      end

      it 'returns false if the user is a space auditor' do
        org.add_user(user)
        space.add_auditor(user)

        can_write_to_space = subject.can_write_to_space?(space)

        expect(can_write_to_space).to equal(false)
      end

      it 'returns false if the user is a manager for the parent org' do
        org.add_user(user)
        org.add_manager(user)

        can_write_to_space = subject.can_write_to_space?(space)

        expect(can_write_to_space).to equal(false)
      end

      it 'returns false if the user is not associated with the space' do
        org.add_user(user)

        can_write_to_space = subject.can_write_to_space?(space)

        expect(can_write_to_space).to equal(false)
      end
    end
  end
end
