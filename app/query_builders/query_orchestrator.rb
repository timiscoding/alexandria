class QueryOrchestrator
  ACTIONS = [:filter, :eager_load, :sort, :paginate]

  def initialize(scope:, params:, request:, response:, actions: :ALL)
    @scope = scope
    @params = params
    @request = request
    @response = response
    @actions = actions == :ALL ? ACTIONS : actions
  end

  def run
    @actions.each do |action|
      unless ACTIONS.include?(action)
        raise InvalidBuilderAction, "#{action} not permitted"
      end

      @scope = send(action)
    end
    @scope
  end

  private

  def filter
    Filter.new(@scope, @params.to_unsafe_hash).filter
  end

  def sort
    Sorter.new(@scope, @params).sort
  end

  def paginate
    current_url = @request.base_url + @request.path
    paginator = Paginator.new(@scope, @request.query_parameters, current_url)
    @response.headers['Link'] = paginator.links
    paginator.paginate
  end

  def eager_load
    EagerLoader.new(@scope, @params).load
  end
end
