require 'spec_helper'

module VCAP::CloudController
  RSpec.describe RouteMappingDelete do
    subject(:route_mapping_delete) { RouteMappingDelete.new(user_audit_info) }
    let(:logger) { instance_double(Steno::Logger) }
    let(:user) { User.make }
    let(:user_email) { 'user_email' }
    let(:user_audit_info) { UserAuditInfo.new(user_guid: user.guid, user_email: user_email) }
    let(:space) { Space.make }
    let(:app) { AppModel.make(space: space) }
    let(:route) { Route.make(space: space) }
    let(:another_route) { Route.make(space: space) }
    let!(:route_mapping) { RouteMappingModel.make(app: app, route: route, process_type: 'other', guid: 'go wild') }
    let!(:another_route_mapping) { RouteMappingModel.make(app: app, route: another_route, process_type: 'other', guid: 'go nuts') }
    let(:route_handler) { instance_double(ProcessRouteHandler, update_route_information: nil) }
    let(:event_repository) { instance_double(Repositories::AppEventRepository) }

    before do
      allow(ProcessRouteHandler).to receive(:new).and_return(route_handler)
      allow(Repositories::AppEventRepository).to receive(:new).and_return(event_repository)
      allow(event_repository).to receive(:record_unmap_route)
    end

    describe '#unmap' do
      it 'can unmap a single route mapping without deleting the route mapping' do
        route_mapping_delete.unmap(route_mapping)
        expect(route_mapping.exists?).to be_truthy
      end

      it 'delegates to the route handler to update route information without process validation' do
        route_mapping_delete.unmap(route_mapping)
        expect(route_handler).to have_received(:update_route_information).with(perform_validation: false)
      end

      it 'records an event for unmapping a route to an app' do
        route_mapping_delete.unmap(route_mapping)

        expect(event_repository).to have_received(:record_unmap_route).with(
          app,
          route,
          user_audit_info,
          route_mapping.guid,
          route_mapping.process_type
        )
      end
    end

    describe '#unmap_all' do
      it 'can unmap multiple route mappings without deleting the route mappings' do
        route_mapping_delete.unmap_all([route_mapping, another_route_mapping])
        expect(route_mapping.exists?).to be_truthy
        expect(another_route_mapping.exists?).to be_truthy
      end

      it 'delegates to the route handler to update route information without process validation' do
        route_mapping_delete.unmap_all([route_mapping, another_route_mapping])
        expect(route_handler).to have_received(:update_route_information).twice.with(perform_validation: false)
      end

      it 'records an event for unmapping a route to an app' do
        route_mapping_delete.unmap_all([route_mapping, another_route_mapping])

        expect(event_repository).to have_received(:record_unmap_route).with(
          app,
          route,
          user_audit_info,
          route_mapping.guid,
          route_mapping.process_type
        )

        expect(event_repository).to have_received(:record_unmap_route).with(
          app,
          another_route,
          user_audit_info,
          another_route_mapping.guid,
          another_route_mapping.process_type
        )
      end
    end

    describe '#delete' do
      context 'when a route mapping exisits in the database' do
        it 'deletes the route from the app' do
          expect(app.reload.routes).not_to be_empty
          route_mapping_delete.delete(route_mapping)
          expect(app.reload.routes).not_to include(route_mapping.route)
        end

        it 'can delete a single route mapping' do
          route_mapping_delete.delete(route_mapping)
          expect(route_mapping.exists?).to be_falsey
        end

        it 'delegates to the route handler to update route information without process validation' do
          route_mapping_delete.delete(route_mapping)
          expect(route_handler).to have_received(:update_route_information).with(perform_validation: false)
        end

        it 'records an event for unmapping the route to an app' do
          route_mapping_delete.delete(route_mapping)

          expect(event_repository).to have_received(:record_unmap_route).with(
            app,
            route,
            user_audit_info,
            route_mapping.guid,
            route_mapping.process_type
          )
        end
      end

      context 'when expected route mappings are not present in the database' do
        before do
          route_mapping.destroy
        end

        it 'does no harm and gracefully continues' do
          expect { route_mapping_delete.delete(route_mapping) }.not_to raise_error
        end

        it 'does delegate to the route handler to update route information' do
          route_mapping_delete.delete(route_mapping)
          expect(route_handler).to have_received(:update_route_information)
        end

        it 'still records an event for un mapping a route to an app' do
          route_mapping_delete.delete(route_mapping)

          expect(event_repository).to have_received(:record_unmap_route).with(
            app,
            route,
            user_audit_info,
            route_mapping.guid,
            route_mapping.process_type
          )
        end
      end
    end
  end
end
