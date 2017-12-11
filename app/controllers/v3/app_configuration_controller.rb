require 'fetchers/app_fetcher'

class AppConfigurationController < ApplicationController

  def update
    app, _space, _org = AppFetcher.new.fetch(params[:guid])
    configuration = params[:body][:applications].first

    process = app.processes.first
    process.update(
      memory: configuration[:memory],
      instances: configuration[:instances],
      disk_quota: configuration[:disk_quota],
      stack: Stack.find(name: configuration[:stack])
    )

    render status: :ok, json: {}
  end

  def show
    app, _space, _org = AppFetcher.new.fetch(params[:guid])
    process = app.processes[0]

    render status: :ok, json: {
      "applications": [
        {
          "name": app.name,
          "disk_quota": process.disk_quota,
          "instances": process.instances,
          "memory": process.memory,
          "routes": [{route: app.routes.first.uri}],
          "stack": process.stack.name
        }
      ]
    }
  end
end
