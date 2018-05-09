module VCAP::CloudController
  class DeploymentCreate
    def create(app:)
      deployment = DeploymentModel.create(app: app, state: DeploymentModel::DEPLOYING_STATE, droplet: app.droplet)

      process_type = "web-deployment-#{deployment.guid}"
      ProcessModel.create(
        # route_guids:                request_attrs['route_guids'],
        app: app,
        type: process_type,
        state: ProcessModel::STARTED
      )
      # ?# app.droplet.process_types[process_type] = app.droplet.process_types['web']

      deployment
    end
  end
end
