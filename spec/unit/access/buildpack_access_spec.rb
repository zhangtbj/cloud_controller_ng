require 'spec_helper'

module VCAP::CloudController
  RSpec.describe BuildpackAccess, type: :access do
    let(:user) { VCAP::CloudController::User.make }
    let(:object) { VCAP::CloudController::Buildpack.make }

    subject { BuildpackAccess.new(Security::AccessContext.new) }

    index_table = {
      unauthenticated: true,
      reader_and_writer: true,
      reader: true,
      writer: true,

      admin: true,
      admin_read_only: true,
      global_auditor: true,
    }

    read_table = {
      unauthenticated: false,
      reader_and_writer: true,
      reader: true,
      writer: false,

      admin: true,
      admin_read_only: true,
      global_auditor: true,
    }

    write_table = {
      unauthenticated: false,
      reader_and_writer: false,
      reader: false,
      writer: false,

      admin: true,
      admin_read_only: false,
      global_auditor: false,
    }

    it_behaves_like('an access control', :create, write_table)
    it_behaves_like('an access control', :delete, write_table)
    it_behaves_like('an access control', :index, index_table)
    it_behaves_like('an access control', :read, read_table)
    it_behaves_like('an access control', :read_for_update, write_table)
    it_behaves_like('an access control', :update, write_table)
    it_behaves_like('an access control', :upload, write_table)
  end
end
