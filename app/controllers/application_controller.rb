class ApplicationController < ActionController::API
  rescue_from QueryBuilderError, with: :builder_error
  rescue_from  RepresentationBuilderError, with: :builder_error

  protected



  def builder_error(error)
    render status: 400, json: {
      error: {
        type: error.class,
        message: error.message,
        invalid_params: error.invalid_params
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
end
