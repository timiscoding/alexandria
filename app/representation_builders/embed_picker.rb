class EmbedPicker
  def initialize(presenter)
    @presenter = presenter
  end

  def embed
    return @presenter unless embeds.any?
    embeds.each { |embed| build_embed(embed) }
    @presenter
  end

  def embeds
    @embeds ||= validate_embeds
  end

  private

  def build_embed(embed)
    embed_presenter = "#{relations[embed].class_name}Presenter".constantize
    entity = @presenter.object.send(embed)

    @presenter.data[embed] =  if relations[embed].collection?
                                entity.order(:id).map do |embedded_entity|
                                  FieldPicker.new(embed_presenter.new(embedded_entity, {})).pick.data
                                end
                              else
                                entity ? FieldPicker.new(embed_presenter.new(entity, {})).pick.data : {}
                              end
  end

  def validate_embeds
    return [] if @presenter.params[:embed].blank?

    embeds = @presenter.params[:embed].try(:split, ',') || []

    return [] unless embeds.any?

    embeds.each do |embed|
      error!(embed) unless @presenter.class.relations.include?(embed)
    end

    embeds
  end

  def error!(embed)
    raise RepresentationBuilderError.new("embed=#{embed}"),
    "Invalid Embed. Allowed relations: (#{@presenter.class.relations.join(',')})"
  end

  def relations
    @relations ||= compute_relations
  end

  def compute_relations
    associations = @presenter.object.class.reflect_on_all_associations

    associations.each_with_object({}) do |r, hash|
      hash["#{r.name}"] = r
    end
  end
end
