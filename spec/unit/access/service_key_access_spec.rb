require 'spec_helper'

module VCAP::CloudController
  RSpec.describe ServiceKeyAccess, type: :access do
    subject(:access) { ServiceKeyAccess.new(Security::AccessContext.new) }
    let(:scopes) { ['cloud_controller.read', 'cloud_controller.write'] }
    let(:user) { VCAP::CloudController::User.make }
    let(:service) { VCAP::CloudController::Service.make }
    let(:org) { VCAP::CloudController::Organization.make }
    let(:space) { VCAP::CloudController::Space.make(organization: org) }
    let(:service_instance) { VCAP::CloudController::ManagedServiceInstance.make(space: space) }

    let(:object) { VCAP::CloudController::ServiceKey.make(name: 'fake-key', service_instance: service_instance) }

    index_table = {
      unauthenticated: true,
      reader_and_writer: true,
      reader: true,
      writer: true,

      admin: true,
      admin_read_only: true,
      global_auditor: true,

      space_developer: true,
      space_manager: true,
      space_auditor: true,
      org_user: true,
      org_manager: true,
      org_auditor: true,
      org_billing_manager: true,
    }

    read_table = {
      unauthenticated: false,
      reader_and_writer: false,
      reader: false,
      writer: false,

      admin: true,
      admin_read_only: true,
      global_auditor: false,

      space_developer: true,
      space_manager: false,
      space_auditor: false,
      org_user: false,
      org_manager: false,
      org_auditor: false,
      org_billing_manager: false,
    }

    describe 'when the service key is in a suspended org' do
      before(:each) do
        org.status = VCAP::CloudController::Organization::SUSPENDED
        org.save
      end

      write_table = {
        unauthenticated: false,
        reader_and_writer: false,
        reader: false,
        writer: false,

        admin: true,
        admin_read_only: false,
        global_auditor: false,

        space_developer: false,
        space_manager: false,
        space_auditor: false,
        org_user: false,
        org_manager: false,
        org_auditor: false,
        org_billing_manager: false,
      }

      it_behaves_like('an access control', :create, write_table)
      it_behaves_like('an access control', :delete, write_table)
      it_behaves_like('an access control', :index, index_table)
      it_behaves_like('an access control', :read, read_table)
      it_behaves_like('an access control', :read_env, read_table)
      it_behaves_like('an access control', :read_for_update, write_table)
      it_behaves_like('an access control', :update, write_table)
    end

    describe 'when the service key is not in a suspended org' do
      write_table = {
        unauthenticated: false,
        reader_and_writer: false,
        reader: false,
        writer: false,

        admin: true,
        admin_read_only: false,
        global_auditor: false,

        space_developer: true,
        space_manager: false,
        space_auditor: false,
        org_user: false,
        org_manager: false,
        org_auditor: false,
        org_billing_manager: false,
      }

      update_table = {
        unauthenticated: false,
        reader_and_writer: false,
        reader: false,
        writer: false,

        admin: true,
        admin_read_only: false,
        global_auditor: false,

        space_developer: false,
        space_manager: false,
        space_auditor: false,
        org_user: false,
        org_manager: false,
        org_auditor: false,
        org_billing_manager: false,
      }

      it_behaves_like('an access control', :create, write_table)
      it_behaves_like('an access control', :delete, write_table)
      it_behaves_like('an access control', :index, index_table)
      it_behaves_like('an access control', :read, read_table)
      it_behaves_like('an access control', :read_env, read_table)
      it_behaves_like('an access control', :read_for_update, update_table)
      it_behaves_like('an access control', :update, update_table)
    end
  end
end
