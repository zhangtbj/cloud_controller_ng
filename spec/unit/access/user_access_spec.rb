require 'spec_helper'

module VCAP::CloudController
  RSpec.describe UserAccess, type: :access do
    subject { UserAccess.new(Security::AccessContext.new) }

    let(:object) { VCAP::CloudController::User.make }
    let(:user) { VCAP::CloudController::User.make }

    before(:each) {
      set_current_user(user)
    }

    index_table = {
      unauthenticated: false,
      reader_and_writer: false,
      reader: false,
      writer: false,

      admin: true,
      admin_read_only: true,
      global_auditor: false,
    }

    read_table = {
      unauthenticated: false,
      reader_and_writer: false,
      reader: false,
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
    it_behaves_like('an access control', :read_for_update, write_table)
    it_behaves_like('an access control', :update, write_table)

    describe '#index?' do
      describe 'with no related_model' do
        let(:op_params) { {} }

        index_table = {
          unauthenticated: false,
          reader_and_writer: false,
          reader: false,
          writer: false,

          admin: true,
          admin_read_only: true,
          global_auditor: false,
        }

        it_behaves_like('an access control', :index, index_table)
      end

      describe 'with Organization as the related_model' do
        let(:op_params) { { related_model: VCAP::CloudController::Organization } }

        index_table = {
          unauthenticated: true,
          reader_and_writer: true,
          reader: true,
          writer: true,

          admin: true,
          admin_read_only: true,
          global_auditor: true,
        }

        it_behaves_like('an access control', :index, index_table)
      end

      describe 'with Space as the related_model' do
        let(:op_params) { { related_model: VCAP::CloudController::Space } }

        index_table = {
          unauthenticated: true,
          reader_and_writer: true,
          reader: true,
          writer: true,

          admin: true,
          admin_read_only: true,
          global_auditor: true,
        }

        it_behaves_like('an access control', :index, index_table)
      end

      describe 'with something else as the related_model' do
        let(:op_params) { { related_model: VCAP::CloudController::User } }

        index_table = {
          unauthenticated: false,
          reader_and_writer: false,
          reader: false,
          writer: false,

          admin: true,
          admin_read_only: true,
          global_auditor: false,
        }

        it_behaves_like('an access control', :index, index_table)
      end
    end

    describe '#read?' do
      describe 'when the user is requesting their own profile' do
        let(:object) { user }
        let(:context) { spy(Security::AccessContext) }

        subject { UserAccess.new(context) }

        before(:each) {
          allow(context).to receive(:user).and_return(user)
        }

        read_table = {
          reader_and_writer: true,
          reader: true,
          writer: true,
        }

        it_behaves_like('an access control', :read, read_table)
      end

      describe 'when the user is requesting a different profile' do
        read_table = {
          unauthenticated: false,
          reader_and_writer: false,
          reader: false,
          writer: false,

          admin: true,
          admin_read_only: true,
          global_auditor: false,
        }

        it_behaves_like('an access control', :read, read_table)
      end
    end
  end
end
