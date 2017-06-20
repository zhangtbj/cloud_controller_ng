require 'spec_helper'
require 'fetchers/v2/service_bindings_fetcher'

module VCAP::CloudController
  RSpec.describe ServiceBindingsFetcher do
    subject(:fetcher) { ServiceBindingsFetcher.new }
    describe '#fetch' do
      context 'when given a user' do
        let(:user_id) { 'test-user-id' }
        let(:acl_data) { { 'accessControlEntries' => acl_statements } }

        let!(:org) { Organization.make }
        let!(:space) { Space.make(organization: org) }

        before do
          stub_request(:get, 'http://acl-service.capi.land/acl').to_return(body: acl_data.to_json)
        end

        context 'when the acl is scoped to a specific app' do
          let!(:app_model) { AppModel.make(space: space) }
          let!(:service_instance) { ManagedServiceInstance.make(space_guid: space.guid) }
          let(:acl_statements) do
            [
              {
                'subject': user_id,
                'action': 'read',
                'resource': "urn:app:/#{org.guid}/#{space.guid}/#{app_model.guid}"
              }
            ]
          end

          it 'only shows service bindings for a specific app' do
            app1_binding = ServiceBinding.make(service_instance: service_instance, app: app_model)
            app1_binding2 = ServiceBinding.make(service_instance: ManagedServiceInstance.make(space_guid: space.guid), app: app_model)
            ServiceBinding.make(service_instance: ManagedServiceInstance.make(space_guid: space.guid), app: AppModel.make(space: space))

            dataset = fetcher.fetch(user_id, false)
            expect(dataset.all.map(&:guid)).to match_array([app1_binding.guid, app1_binding2.guid])
          end
        end

        context 'when the acl is scoped to a several specific apps' do
          let!(:app_model) { AppModel.make(space: space) }
          let!(:app_model2) { AppModel.make(space: space) }
          let!(:service_instance) { ManagedServiceInstance.make(space_guid: space.guid) }
          let(:acl_statements) do
            [
              {
                'subject': user_id,
                'action': 'read',
                'resource': "urn:app:/#{org.guid}/#{space.guid}/#{app_model.guid}"
              },
              {
                'subject': user_id,
                'action': 'read',
                'resource': "urn:app:/#{org.guid}/#{space.guid}/#{app_model2.guid}"
              }
            ]
          end

          it 'only shows service bindings for a specific app' do
            app1_binding = ServiceBinding.make(service_instance: service_instance, app: app_model)
            app2_binding = ServiceBinding.make(service_instance: service_instance, app: app_model2)
            ServiceBinding.make(service_instance: ManagedServiceInstance.make(space_guid: space.guid), app: AppModel.make(space: space))

            dataset = fetcher.fetch(user_id, false)
            expect(dataset.all.map(&:guid)).to match_array([app1_binding.guid, app2_binding.guid])
          end
        end

        context 'when the acl is scoped to apps in a space' do
          let!(:app_model) { AppModel.make(space: space) }
          let!(:app_model2) { AppModel.make(space: space) }
          let!(:service_instance) { ManagedServiceInstance.make(space_guid: space.guid) }
          let!(:other_space) { Space.make(organization: org) }

          let(:acl_statements) do
            [
              {
                'subject': user_id,
                'action': 'read',
                'resource': "urn:app:/#{org.guid}/#{space.guid}/*"
              }
            ]
          end

          it 'only shows service bindings for all apps in the space' do
            app1_binding = ServiceBinding.make(service_instance: service_instance, app: app_model)
            app2_binding = ServiceBinding.make(service_instance: service_instance, app: app_model2)
            ServiceBinding.make(service_instance: ManagedServiceInstance.make(space_guid: other_space.guid), app: AppModel.make(space: other_space))

            dataset = fetcher.fetch(user_id, false)
            expect(dataset.all.map(&:guid)).to match_array([app1_binding.guid, app2_binding.guid])
          end
        end

        context 'when the acl is scoped to apps in an org' do
          let!(:app_model) { AppModel.make(space: space) }
          let!(:app_model2) { AppModel.make(space: space) }
          let!(:service_instance) { ManagedServiceInstance.make(space_guid: space.guid) }
          let!(:other_org) { Organization.make }
          let!(:other_space) { Space.make(organization: other_org) }

          let(:acl_statements) do
            [
              {
                'subject': user_id,
                'action': 'read',
                'resource': "urn:app:/#{org.guid}/*"
              }
            ]
          end

          it 'only shows service bindings for all apps in the space' do
            app1_binding = ServiceBinding.make(service_instance: service_instance, app: app_model)
            app2_binding = ServiceBinding.make(service_instance: service_instance, app: app_model2)
            ServiceBinding.make(service_instance: ManagedServiceInstance.make(space_guid: other_space.guid), app: AppModel.make(space: other_space))

            dataset = fetcher.fetch(user_id, false)
            expect(dataset.all.map(&:guid)).to match_array([app1_binding.guid, app2_binding.guid])
          end
        end

        context 'when the ace gives access to all apps' do
          let!(:app_model) { AppModel.make(space: space) }
          let!(:app_model2) { AppModel.make(space: space) }
          let!(:service_instance) { ManagedServiceInstance.make(space_guid: space.guid) }
          let!(:org2) { Organization.make }
          let!(:space2) { Space.make(organization: org2) }

          let(:acl_statements) do
            [
              {
                'subject': user_id,
                'action': 'read',
                'resource': "urn:app:/*"
              }
            ]
          end

          it 'only shows service bindings for all apps in the space' do
            app1_binding = ServiceBinding.make(service_instance: service_instance, app: app_model)
            app2_binding = ServiceBinding.make(service_instance: service_instance, app: app_model2)
            app3_binding = ServiceBinding.make(service_instance: ManagedServiceInstance.make(space_guid: space2.guid), app: AppModel.make(space: space2))

            dataset = fetcher.fetch(user_id, false)
            expect(dataset.all.map(&:guid)).to match_array([app1_binding.guid, app2_binding.guid, app3_binding.guid])
          end
        end

        context 'where the acl is empty' do
          let!(:app_model) { AppModel.make(space: space) }
          let!(:service_instance) { ManagedServiceInstance.make(space_guid: space.guid) }

          let(:acl_statements) do
            []
          end

          it 'only shows service bindings for all apps in the space' do
            ServiceBinding.make(service_instance: service_instance, app: app_model)

            dataset = fetcher.fetch(user_id, false)
            expect(dataset.all.map(&:guid)).to match_array([])
          end
        end
      end
    end
  end
end
