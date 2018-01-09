require 'spec_helper'
require 'cloud_controller/security/access_context'

module VCAP::CloudController
  module Security
    RSpec.describe AccessContext do
      let(:permission_queryer) { spy(VCAP::CloudController::Permissions::SecurityContextQueryer) }
      let(:org) { double(VCAP::CloudController::Organization) }
      let(:space) { double(VCAP::CloudController::Space) }

      subject { AccessContext.new(permission_queryer) }

      describe '#can_read_resources?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_read_resources?).and_return('fake read resources')

          expect(subject.can_read_resources?).to eq('fake read resources')
        end
      end

      describe '#can_write_resources?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_write_resources?).and_return('fake write resources')

          expect(subject.can_write_resources?).to eq('fake write resources')
        end
      end

      describe '#can_read_globally?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_read_globally?).and_return('fake read globally')

          expect(subject.can_read_globally?).to eq('fake read globally')
        end
      end

      describe '#can_see_secrets_globally?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_see_secrets_globally?).and_return('fake see secrets globally')

          expect(subject.can_see_secrets_globally?).to eq('fake see secrets globally')
        end
      end

      describe '#can_write_globally?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_write_globally?).and_return('fake write globally')

          expect(subject.can_write_globally?).to eq('fake write globally')
        end
      end

      describe '#can_read_from_org?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_read_from_org?).with(org).and_return('fake read from org')

          expect(subject.can_read_from_org?(org)).to eq('fake read from org')
        end

        it 'returns false if the org does not exist' do
          expect(subject.can_read_from_org?(nil)).to eq(false)
        end
      end

      describe '#can_write_to_org?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_write_to_org?).with(org).and_return('fake write to org')

          expect(subject.can_write_to_org?(org)).to eq('fake write to org')
        end

        it 'returns false if the org does not exist' do
          expect(subject.can_write_to_org?(nil)).to eq(false)
        end
      end

      describe '#can_read_from_space?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_read_from_space?).with(space, org).and_return('fake read from space')

          expect(subject.can_read_from_space?(space, org)).to eq('fake read from space')
        end

        it 'returns false if the space does not exist' do
          expect(subject.can_read_from_space?(nil, org)).to eq(false)
        end

        it 'returns false if the org does not exist' do
          expect(subject.can_read_from_space?(space, nil)).to eq(false)
        end
      end

      describe '#can_see_secrets_in_space?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_see_secrets_in_space?).with(space).and_return('fake see secrets in space')

          expect(subject.can_see_secrets_in_space?(space)).to eq('fake see secrets in space')
        end

        it 'returns false if the space does not exist' do
          expect(subject.can_see_secrets_in_space?(nil)).to eq(false)
        end
      end

      describe '#can_write_to_space?' do
        it 'returns the result from the queryer' do
          allow(permission_queryer).to receive(:can_write_to_space?).with(space).and_return('fake write to space')

          expect(subject.can_write_to_space?(space)).to eq('fake write to space')
        end

        it 'returns false if the space does not exist' do
          expect(subject.can_write_to_space?(nil)).to eq(false)
        end
      end
    end
  end
end
