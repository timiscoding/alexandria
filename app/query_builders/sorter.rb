class Sorter
  DIRECTIONS = %w(asc desc)

  def initialize(scope, params)
    @scope = scope
    @presenter = "#{scope.model}Presenter".constantize
    @column = params[:sort]
    @direction = params[:dir]
  end

  def sort
    return @scope unless @column && @direction

    error!('sort', @column) unless @presenter.sort_attributes.include?(@column)
    error!('dir', @direction) unless DIRECTIONS.include?(@direction)

    @scope.order("#{@column} #{@direction}")
  end

  private

  def error!(name,value)
    columns = @presenter.sort_attributes.join(',')
    raise QueryBuilderError.new("#{name}=#{value}"),
      "Invalid sorting params. sort: (#{columns}), dir: asc,desc"
  end
end
