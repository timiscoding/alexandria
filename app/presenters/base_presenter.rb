class BasePresenter
  @build_attributes = []

  # open the door to class methods
  class << self
    # define accessor for class level instance variable
    attr_accessor :build_attributes

    def build_with(*args)
      @build_attributes = args.map(&:to_s)
    end
  end

  attr_accessor :object, :params, :data

  def initialize(object, params, options = {})
    @object = object
    @params = params
    @options = options
    @data = HashWithIndifferentAccess.new
  end

  def as_json(*)
    @data
  end
end
