module VCAP::CloudController
  class DeploymentCreate

    def create(app:)
      deployment = DeploymentModel.create(app: app, state: DeploymentModel::DEPLOYING_STATE, droplet: app.droplet)

      ProcessModel.create(
        # route_guids:                request_attrs['route_guids'],
        app:                        app,
        type: "web-deployment-#{deployment.guid}"
      )

      deployment
    end
  end
end
