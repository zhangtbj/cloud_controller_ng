require 'spec_helper'

module VCAP::CloudController
  RSpec.describe UaaTimeoutScim do
    let(:timeout) { 0.01.second }
    subject(:uaa_timeout_scim) { UaaTimeoutScim.new(uaa_core_scim, timeout)}
    let(:uaa_core_scim) { instance_double(CF::UAA::Scim, {get: nil, query: nil})}

    describe '#get' do
      it 'calls the core scim' do
        uaa_timeout_scim.get(:foo, 123)
        expect(uaa_core_scim).to have_received(:get).with(:foo, 123)
      end

      context 'when the timeout is exceeded' do
        before do
          allow(uaa_core_scim).to receive(:get) { sleep(2) }
        end

        it 'raises an error after the timeout has elapsed' do
          expect { uaa_timeout_scim.get(:foo, 123) }.to raise_error UaaUnavailable
        end
      end
    end

    describe '#query' do
      it 'calls the core scim' do
        uaa_timeout_scim.query(:user_id, includeInactive: true, filter: 'secret-admins')
        expect(uaa_core_scim).to have_received(:query).with(:user_id, includeInactive: true, filter: 'secret-admins')
      end

      context 'when the timeout is exceeded' do
        before do
          allow(uaa_core_scim).to receive(:query) { sleep(2) }
        end

        it 'raises an error after the timeout has elapsed' do
          expect { uaa_timeout_scim.query(:user_id, includeInactive: true, filter: 'secret-admins') }.to raise_error UaaUnavailable
        end
      end
    end
  end
end
