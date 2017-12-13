require 'fetchers/app_fetcher'

class AppConfigurationController < ApplicationController
  # {
  #   "applications": [
  #     {
  #       "name": app.name,
  #       "disk_quota": process.disk_quota,
  #       "instances": process.instances,
  #       "memory": process.memory,
  #       "routes": [{route: app.routes.first.uri}],
  #       "stack": process.stack.name,
  #       "processes": [
  #         {
  #           "type": "web",
  #           "disk_quota": 1,
  #           "instances": 5,
  #           "memory": 1,
  #           "command": "rackup"
  #         }
  #       ]
  #     }
  #   ]
  # }

  def update
    app, _space, _org = AppFetcher.new.fetch(params[:guid])
    configuration = params[:body][:applications].first

    # if there are isn't a process with the incoming type for the given app,
    configuration[:processes].each do |process_config|
      process_type = process_config[:type]

      # check by looping over process types and matching against configuration process type
      existing_process = app.processes.find { |process| process.type == process_type }

      # create dummy process by calling ProcessCreate.create if there is not existing process
      process =  existing_process || ProcessCreate.new(user_audit_info).create(app, type: process_type, command: '')

      # update process with configuration attrs
      process.update(process_config)

      # TODO: Use ProcessUpdate message?
      # messagified_config = VCAP::CloudController::ProcessUpdateMessage.new(process_config.dup)
      # ProcessUpdate.new(user_audit_info).update(process, messagified_config)
    end

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
