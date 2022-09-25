class BasePresenter
  # to generate URLs for cover images, we need to include this
  include Rails.application.routes.url_helpers

  CLASS_ATTRIBUTES = {
    build_with: :build_attributes,
    related_to: :relations,
    sort_by: :sort_attributes,
    filter_by: :filter_attributes
  }

  CLASS_ATTRIBUTES.values.each { |var| instance_variable_set("@#{var}", []) }

  # @build_attributes = []
  # @sort_attributes = []
  # @filter_attributes = []
  # @relations = []

  # open the door to class methods
  class << self
    # define accessor for class level instance variable
    attr_accessor *CLASS_ATTRIBUTES.values

    # attr_accessor :build_attributes, :relations,
    #               :sort_attributes, :filter_attributes

    CLASS_ATTRIBUTES.each do |k, v|
      define_method(k) { |*args| instance_variable_set("@#{v}", args.map(&:to_s)) }
    end

    # def build_with(*args)
    #   @build_attributes = args.map(&:to_s)
    # end

    # def related_to(*args)
    #   @relations = args.map(&:to_s)
    # end

    # def sort_by(*args)
    #   @sort_attributes = args.map(&:to_s)
    # end

    # def filter_by(*args)
    #   @filter_attributes = args.map(&:to_s)
    # end
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

  def fields
    FieldPicker.new(self).pick
  end

  def embeds
    EmbedPicker.new(self).embed
  end

  def build(actions)
    actions.each do |action|
      send(action)
    end
    self
  end
end
