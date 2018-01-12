require 'spec_helper'

module VCAP::CloudController
  RSpec.describe ManagedServiceInstanceAccess, type: :access do
    let(:user) { VCAP::CloudController::User.make }
    let(:service_plan) { VCAP::CloudController::ServicePlan.make(service: service) }

    let(:space) { VCAP::CloudController::Space.make(organization: org) }
    let(:service) { VCAP::CloudController::Service.make }

    let(:object) { VCAP::CloudController::ManagedServiceInstance.make(service_plan: service_plan, space: space) }

    subject { ManagedServiceInstanceAccess.new(Security::AccessContext.new) }

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

    manage_permissions_table = {
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

    purge_table = {
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

    read_env_table = {
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

    read_permissions_table = {
      unauthenticated: false,
      reader_and_writer: false,
      reader: false,
      writer: false,

      admin: true,
      admin_read_only: true,
      global_auditor: false,

      space_developer: true,
      space_manager: true,
      space_auditor: true,
      org_user: false,
      org_manager: true,
      org_auditor: false,
      org_billing_manager: false,
    }

    context 'when the service plan is active' do
      let(:service_plan) { VCAP::CloudController::ServicePlan.make(service: service, active: true) }

      context 'when the org is active' do
        let(:org) { VCAP::CloudController::Organization.make(status: VCAP::CloudController::Organization::ACTIVE) }

        context 'when the service instance creation flag is enabled' do
          before(:each) do
            FeatureFlag.make(name: 'service_instance_creation', enabled: true)
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

          it_behaves_like('an access control', :manage_permissions, manage_permissions_table)
          it_behaves_like('an access control', :purge, purge_table)
          it_behaves_like('an access control', :read_env, read_env_table)
          it_behaves_like('an access control', :read_permissions, read_permissions_table)
        end

        context 'when the service instance creation flag is disabled' do
          before(:each) do
            FeatureFlag.make(name: 'service_instance_creation', enabled: false)
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

          create_table = {
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

          it_behaves_like('a feature flag-disabled access control', :create, create_table)
          it_behaves_like('a feature flag-disabled access control', :delete, write_table)
          it_behaves_like('a feature flag-disabled access control', :index, index_table)
          it_behaves_like('a feature flag-disabled access control', :read, read_table)
          it_behaves_like('a feature flag-disabled access control', :read_for_update, write_table)
          it_behaves_like('a feature flag-disabled access control', :update, write_table)

          it_behaves_like('a feature flag-disabled access control', :manage_permissions, manage_permissions_table)
          it_behaves_like('a feature flag-disabled access control', :purge, purge_table)
          it_behaves_like('a feature flag-disabled access control', :read_env, read_env_table)
          it_behaves_like('a feature flag-disabled access control', :read_permissions, read_permissions_table)
        end
      end

      context 'when the org is suspended' do
        let(:org) { VCAP::CloudController::Organization.make(status: VCAP::CloudController::Organization::SUSPENDED) }

        context 'when the service instance creation flag is enabled' do
          before(:each) do
            FeatureFlag.make(name: 'service_instance_creation', enabled: true)
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

          it_behaves_like('an access control', :manage_permissions, manage_permissions_table)
          it_behaves_like('an access control', :purge, purge_table)
          it_behaves_like('an access control', :read_env, read_env_table)
          it_behaves_like('an access control', :read_permissions, read_permissions_table)
        end

        context 'when the service instance creation flag is disabled' do
          before(:each) do
            FeatureFlag.make(name: 'service_instance_creation', enabled: false)
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

          it_behaves_like('a feature flag-disabled access control', :create, write_table)
          it_behaves_like('a feature flag-disabled access control', :delete, write_table)
          it_behaves_like('a feature flag-disabled access control', :index, index_table)
          it_behaves_like('a feature flag-disabled access control', :read, read_table)
          it_behaves_like('a feature flag-disabled access control', :read_for_update, write_table)
          it_behaves_like('a feature flag-disabled access control', :update, write_table)

          it_behaves_like('a feature flag-disabled access control', :manage_permissions, manage_permissions_table)
          it_behaves_like('a feature flag-disabled access control', :purge, purge_table)
          it_behaves_like('a feature flag-disabled access control', :read_env, read_env_table)
          it_behaves_like('a feature flag-disabled access control', :read_permissions, read_permissions_table)
        end
      end
    end

    context 'when the service plan is inactive' do
      let(:service_plan) { VCAP::CloudController::ServicePlan.make(service: service, active: false) }

      context 'when the org is active' do
        let(:org) { VCAP::CloudController::Organization.make(status: VCAP::CloudController::Organization::ACTIVE) }

        context 'when the service instance creation flag is enabled' do
          before(:each) do
            FeatureFlag.make(name: 'service_instance_creation', enabled: true)
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

          delete_table = {
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
          it_behaves_like('an access control', :delete, delete_table)
          it_behaves_like('an access control', :index, index_table)
          it_behaves_like('an access control', :read, read_table)
          it_behaves_like('an access control', :read_for_update, delete_table)
          it_behaves_like('an access control', :update, write_table)

          it_behaves_like('an access control', :manage_permissions, manage_permissions_table)
          it_behaves_like('an access control', :purge, purge_table)
          it_behaves_like('an access control', :read_env, read_env_table)
          it_behaves_like('an access control', :read_permissions, read_permissions_table)
        end

        context 'when the service instance creation flag is disabled' do
          before(:each) do
            FeatureFlag.make(name: 'service_instance_creation', enabled: false)
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

          delete_table = {
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

          it_behaves_like('a feature flag-disabled access control', :create, write_table)
          it_behaves_like('a feature flag-disabled access control', :delete, delete_table)
          it_behaves_like('a feature flag-disabled access control', :index, index_table)
          it_behaves_like('a feature flag-disabled access control', :read, read_table)
          it_behaves_like('a feature flag-disabled access control', :read_for_update, delete_table)
          it_behaves_like('a feature flag-disabled access control', :update, write_table)

          it_behaves_like('a feature flag-disabled access control', :manage_permissions, manage_permissions_table)
          it_behaves_like('a feature flag-disabled access control', :purge, purge_table)
          it_behaves_like('a feature flag-disabled access control', :read_env, read_env_table)
          it_behaves_like('a feature flag-disabled access control', :read_permissions, read_permissions_table)
        end
      end

      context 'when the org is suspended' do
        let(:org) { VCAP::CloudController::Organization.make(status: VCAP::CloudController::Organization::SUSPENDED) }

        context 'when the service instance creation flag is enabled' do
          before(:each) do
            FeatureFlag.make(name: 'service_instance_creation', enabled: true)
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

          it_behaves_like('an access control', :manage_permissions, manage_permissions_table)
          it_behaves_like('an access control', :purge, purge_table)
          it_behaves_like('an access control', :read_env, read_env_table)
          it_behaves_like('an access control', :read_permissions, read_permissions_table)
        end

        context 'when the service instance creation flag is disabled' do
          before(:each) do
            FeatureFlag.make(name: 'service_instance_creation', enabled: false)
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

          it_behaves_like('a feature flag-disabled access control', :create, write_table)
          it_behaves_like('a feature flag-disabled access control', :delete, write_table)
          it_behaves_like('a feature flag-disabled access control', :index, index_table)
          it_behaves_like('a feature flag-disabled access control', :read, read_table)
          it_behaves_like('a feature flag-disabled access control', :read_for_update, write_table)
          it_behaves_like('a feature flag-disabled access control', :update, write_table)

          it_behaves_like('a feature flag-disabled access control', :manage_permissions, manage_permissions_table)
          it_behaves_like('a feature flag-disabled access control', :purge, purge_table)
          it_behaves_like('a feature flag-disabled access control', :read_env, read_env_table)
          it_behaves_like('a feature flag-disabled access control', :read_permissions, read_permissions_table)
        end
      end
    end
  end
end
