require 'spec_helper'

module VCAP::CloudController
  RSpec.describe RouteMappingModelAccess, type: :access do
    subject(:access) { RouteMappingModelAccess.new(Security::AccessContext.new) }
    let(:scopes) { ['cloud_controller.read', 'cloud_controller.write'] }

    let(:user) { VCAP::CloudController::User.make }
    let(:org) { VCAP::CloudController::Organization.make }
    let(:space) { VCAP::CloudController::Space.make(organization: org) }
    let(:domain) { VCAP::CloudController::PrivateDomain.make(owning_organization: org) }
    let(:process) { VCAP::CloudController::ProcessModelFactory.make(space: space) }
    let(:route) { VCAP::CloudController::Route.make(domain: domain, space: space) }
    let(:object) { VCAP::CloudController::RouteMappingModel.make(route: route, app: process) }

    before { set_current_user(user, scopes: scopes) }

    describe 'when the org is suspended' do
      before(:each) do
        org.status = VCAP::CloudController::Organization::SUSPENDED
        org.save
      end

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
        global_auditor: true,

        space_developer: true,
        space_manager: true,
        space_auditor: true,
        org_user: false,
        org_manager: true,
        org_auditor: false,
        org_billing_manager: false,
      }

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
      it_behaves_like('an access control', :read_for_update, write_table)
      it_behaves_like('an access control', :update, write_table)
    end

    describe 'when the org is not suspended' do
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
        global_auditor: true,

        space_developer: true,
        space_manager: true,
        space_auditor: true,
        org_user: false,
        org_manager: true,
        org_auditor: false,
        org_billing_manager: false,
      }

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

      it_behaves_like('an access control', :create, write_table)
      it_behaves_like('an access control', :delete, write_table)
      it_behaves_like('an access control', :index, index_table)
      it_behaves_like('an access control', :read, read_table)
      it_behaves_like('an access control', :read_for_update, write_table)
      it_behaves_like('an access control', :update, write_table)
    end
  end
end
