require 'spec_helper'
require 'actions/route_update'

module VCAP::CloudController
  RSpec.describe RouteUpdate do
    subject(:route_update) { RouteUpdate.new(user_audit_info) }

    let(:message) { ManifestRoutesMessage.new({ routes: { 'route': 'http://host.some-domain.com'} }) }

    let!(:route) do
      Route.make(
        host: 'existing-host',
        path: '/some-path',
        domain: SharedDomain.make(name: 'example.com')
      )
    end

    let(:user_audit_info) { instance_double(UserAuditInfo).as_null_object }

    describe '#update' do
      it 'updates the requested changes on the route' do
        route_update.update(route, message)
        route.reload
        expect(route.domain).to eq('some-domain.com')
      end

      context 'when no changes are requested' do
        let(:message) { ManifestRoutesMessage.new({}) }

        it 'does not update the process' do
          route_update.update(route, message)

          route.reload
          expect(route.host).to eq('some-host')
        end
      end

      it 'creates an audit event' do
        expect(Repositories::RouteEventRepository).to receive(:record_update).with(
          route,
          user_audit_info,
          {
            route: 'http://ma-domain.com',
          }
        )

        route_update.update(route, message)
      end

    end
  end
end
