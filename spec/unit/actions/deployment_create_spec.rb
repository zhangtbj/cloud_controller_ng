require 'spec_helper'
require 'actions/deployment_create'

module VCAP::CloudController
  RSpec.describe DeploymentCreate do
    subject(:action) do
      DeploymentCreate.new
    end
    let(:app) { VCAP::CloudController::AppModel.make(droplet: droplet) }
    let(:droplet) { VCAP::CloudController::DropletModel.make }

    describe '#create' do
      it 'creates a deployment' do
        deployment = nil

        expect {
          deployment = action.create(app: app)
        }.to change { DeploymentModel.count }.by(1)

        expect(deployment.state).to eq(DeploymentModel::DEPLOYING_STATE)
        expect(deployment.app_guid).to eq(app.guid)
        expect(deployment.droplet_guid).to eq(droplet.guid)
      end

      it 'creates a process of web-deployment type' do
        deployment = nil

        expect {
          deployment = action.create(app: app)
        }.to change { ProcessModel.count }.by(1)

        expect(app.processes.collect(&:type)).to include("web-deployment-#{deployment.guid}")
      end
    end
  end
end
