require 'spec_helper'

module VCAP::CloudController
  RSpec.describe ServicePlanVisibilityAccess, type: :access do
    subject(:access) { ServicePlanVisibilityAccess.new(Security::AccessContext.new) }

    let(:user) { VCAP::CloudController::User.make }
    let(:service) { VCAP::CloudController::Service.make }
    let(:org) { VCAP::CloudController::Organization.make }
    let(:service_plan) { VCAP::CloudController::ServicePlan.make(service: service) }

    let(:object) { VCAP::CloudController::ServicePlanVisibility.make(organization: org, service_plan: service_plan) }

    before { set_current_user(user) }

    index_table = {
      unauthenticated: true,
      reader_and_writer: true,
      reader: true,
      writer: true,

      admin: true,
      admin_read_only: true,
      global_auditor: true,

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
