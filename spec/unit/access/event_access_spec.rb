require 'spec_helper'

module VCAP::CloudController
  RSpec.describe EventAccess, type: :access do
    let(:user) { VCAP::CloudController::User.make }
    let(:org) { VCAP::CloudController::Organization.make }
    let(:space) { VCAP::CloudController::Space.make(organization: org) }
    let(:object) { VCAP::CloudController::Event.make(space: space) }

    subject { EventAccess.new(Security::AccessContext.new) }

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
end
