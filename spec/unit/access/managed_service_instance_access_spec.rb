require 'spec_helper'

module VCAP::CloudController
  RSpec.describe ManagedServiceInstanceAccess, type: :access do
    let(:user) { VCAP::CloudController::User.make }
    let(:org) { VCAP::CloudController::Organization.make }
    let(:space) { VCAP::CloudController::Space.make(organization: org) }
    let(:service) { VCAP::CloudController::Service.make }
    let(:service_plan) { VCAP::CloudController::ServicePlan.make(service: service) }
    let(:object) { VCAP::CloudController::ManagedServiceInstance.make(service_plan: service_plan, space: space) }

    subject { ManagedServiceInstanceAccess.new(Security::AccessContext.new) }

    context 'when the service plan is active' do
      context 'when the service instance creation flag is enabled' do
        context 'when the org is suspended' do

        end

        context 'when the org is not suspended' do

        end
      end

      context 'when the service instance creation flag is disabled' do
        context 'when the org is suspended' do

        end

        context 'when the org is not suspended' do

        end
      end

      let(:service_plan) { VCAP::CloudController::ServicePlan.make(service: service, active: true) }
      let(:object) { VCAP::CloudController::ManagedServiceInstance.make(service_plan: service_plan, space: space) }

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
        space_manager: false,
        space_auditor: true,
        org_user: false,
        org_manager: false,
        org_auditor: true,
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

    context 'when the service plan is inactive' do
      context 'when the service instance creation flag is enabled' do
        before(:each) do
          FeatureFlag.make(name: 'service_instance_creation', enabled: true)
        end

        context 'when the org is suspended' do

        end

        context 'when the org is not suspended' do

        end
      end

      context 'when the service instance creation flag is disabled' do
        context 'when the org is suspended' do

        end

        context 'when the org is not suspended' do

        end
      end

      let(:service_plan) { VCAP::CloudController::ServicePlan.make(service: service, active: false) }
      let(:object) { VCAP::CloudController::ManagedServiceInstance.make(service_plan: service_plan, space: space) }

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
        space_manager: false,
        space_auditor: true,
        org_user: false,
        org_manager: false,
        org_auditor: true,
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

    before { set_current_user(user) }

    it_behaves_like :admin_read_only_access

    context 'admin' do
      include_context :admin_setup
      it_behaves_like :full_access

      context 'service plan' do
        it 'allowed when the service plan is not visible' do
          new_plan = VCAP::CloudController::ServicePlan.make(active: false)

          object.service_plan = new_plan
          expect(subject.update?(object)).to be_truthy
        end
      end
    end

    context 'space developer' do
      before do
        org.add_user(user)
        space.add_developer(user)
      end

      context 'service plan' do
        it 'allows when the service plan is visible' do
          new_plan = VCAP::CloudController::ServicePlan.make(service: service)
          object.service_plan = new_plan
          expect(subject.create?(object)).to be_truthy
          expect(subject.read_for_update?(object)).to be_truthy
          expect(subject.update?(object)).to be_truthy
        end

        it 'fails when assigning to a service plan that is not visible' do
          new_plan = VCAP::CloudController::ServicePlan.make(active: false)

          object.service_plan = new_plan
          expect(subject.create?(object)).to be_falsey
          expect(subject.update?(object)).to be_falsey
        end

        it 'succeeds when updating from a service plan that is not visible' do
          new_plan = VCAP::CloudController::ServicePlan.make(active: false)

          object.service_plan = new_plan
          expect(subject.read_for_update?(object)).to be_truthy
        end
      end
    end
  end
end
