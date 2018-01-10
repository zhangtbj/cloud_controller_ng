require 'spec_helper'

module VCAP::CloudController
  RSpec.describe AppEventAccess, type: :access do
    subject { AppEventAccess.new(Security::AccessContext.new) }

    let(:user) { VCAP::CloudController::User.make }
    let(:org) { VCAP::CloudController::Organization.make }
    let(:space) { VCAP::CloudController::Space.make(organization: org) }
    let(:process) { VCAP::CloudController::ProcessModelFactory.make(space: space) }
    let(:object) { VCAP::CloudController::AppEvent.make(app: process) }

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

    it_behaves_like('an access class', :create, write_table)
    it_behaves_like('an access class', :delete, write_table)
    it_behaves_like('an access class', :index, index_table)
    it_behaves_like('an access class', :read, read_table)
    it_behaves_like('an access class', :read_for_update, write_table)
    it_behaves_like('an access class', :update, write_table)
  end
end
