class ApplicationController < ActionController::API
  rescue_from QueryBuilderError, with: :builder_error
  rescue_from RepresentationBuilderError, with: :builder_error
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

  protected

  def resource_not_found
    render status: 404
  end

  def builder_error(error)
    render status: 400, json: {
      error: {
        type: error.class,
        message: error.message,
        invalid_params: error.invalid_params
      }
    }
  end

  def unprocessable_entity!(resource)
    render status: :unprocessable_entity, json: {
      error: {
        message: "Invalid parameters for resource: #{resource.class}",
        invalid_params: resource.errors
      }
    }
  end

  def orchestrate_query(scope, actions = :ALL)
    QueryOrchestrator.new(
      scope: scope,
      params: params,
      request: request,
      response: response,
      actions: actions
    ).run
  end

  def serialize(data)
    {
      json: Alexandria::Serializer.new(data: data,
                                      params: params,
                                      actions: [:embeds, :fields]).to_json
      }
  end
end
