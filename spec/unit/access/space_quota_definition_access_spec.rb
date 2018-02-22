require 'spec_helper'

module VCAP::CloudController
  RSpec.describe SpaceQuotaDefinitionAccess, type: :access do
    subject(:access) { SpaceQuotaDefinitionAccess.new(Security::AccessContext.new) }
    let(:user) { VCAP::CloudController::User.make }
    let(:org) { Organization.make }
    let(:space) { Space.make(organization: org) }
    let(:scopes) { nil }
    let(:object) { VCAP::CloudController::SpaceQuotaDefinition.make(organization: org) }

    before { set_current_user(user, scopes: scopes) }

    describe 'when the organization is suspended' do
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

      describe 'when the space is associated with the space quota definition' do
        before(:each) do
          space.space_quota_definition = object
          space.save
        end

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

        it_behaves_like('an access control', :create, write_table)
        it_behaves_like('an access control', :delete, write_table)
        it_behaves_like('an access control', :index, index_table)
        it_behaves_like('an access control', :read, read_table)
        it_behaves_like('an access control', :read_for_update, write_table)
        it_behaves_like('an access control', :update, write_table)
      end

      describe 'when the space is not associated with the space quota definition' do
        read_table = {
          unauthenticated: false,
          reader_and_writer: false,
          reader: false,
          writer: false,

          admin: true,
          admin_read_only: true,
          global_auditor: true,

          space_developer: false,
          space_manager: false,
          space_auditor: false,
          org_user: false,
          org_manager: true,
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

    describe 'when the organization is not suspended' do
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
        org_manager: true,
        org_auditor: false,
        org_billing_manager: false,
      }

      describe 'when the space is associated with the space quota definition' do
        before(:each) do
          space.space_quota_definition = object
          space.save
        end

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

        it_behaves_like('an access control', :create, write_table)
        it_behaves_like('an access control', :delete, write_table)
        it_behaves_like('an access control', :index, index_table)
        it_behaves_like('an access control', :read, read_table)
        it_behaves_like('an access control', :read_for_update, write_table)
        it_behaves_like('an access control', :update, write_table)
      end

      describe 'when the space is not associated with the space quota definition' do
        read_table = {
          unauthenticated: false,
          reader_and_writer: false,
          reader: false,
          writer: false,

          admin: true,
          admin_read_only: true,
          global_auditor: true,

          space_developer: false,
          space_manager: false,
          space_auditor: false,
          org_user: false,
          org_manager: true,
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
end
