require 'spec_helper'

module VCAP::CloudController
  RSpec.describe DomainAccess, type: :access do
    let(:user) { User.make }

    subject { DomainAccess.new(Security::AccessContext.new) }

    context 'when the domain is shared' do
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

      let(:object) { Domain.make }

      it_behaves_like('an access control', :create, write_table)
      it_behaves_like('an access control', :delete, write_table)
      it_behaves_like('an access control', :index, index_table)
      it_behaves_like('an access control', :read, read_table)
      it_behaves_like('an access control', :read_for_update, write_table)
      it_behaves_like('an access control', :update, write_table)
    end

    context 'when the domain is owned by an organization' do
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
        org_manager: true,
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

        org_user: false,
        org_manager: true,
        org_auditor: false,
        org_billing_manager: false,
      }

      let(:org) { Organization.make }
      let(:object) { Domain.make(owning_organization: org) }

      it_behaves_like('an access control', :create, write_table)
      it_behaves_like('an access control', :delete, write_table)
      it_behaves_like('an access control', :index, index_table)
      it_behaves_like('an access control', :read, read_table)
      it_behaves_like('an access control', :read_for_update, write_table)
      it_behaves_like('an access control', :update, write_table)
    end
  end
end
