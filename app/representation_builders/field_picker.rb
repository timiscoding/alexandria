class FieldPicker
  def initialize(presenter)
    @presenter = presenter
  end

  def pick
    build_fields

    @presenter
  end

  # we need to access fields from outside later on
  def fields
    @fields ||= validate_fields
  end

  private
    def validate_fields
      return pickable if @presenter.params[:fields].blank?

      fields = @presenter.params[:fields].split(',')

      return pickable if fields.blank?

      fields.each do |field|
        error!(field) unless pickable.include?(field)
      end

      fields
    end

    def pickable
      @pickable ||= @presenter.class.build_attributes
    end

    def error!(field)
      build_attributes = pickable.join(',')
      raise RepresentationBuilderError.new("fields=#{field}"),
            "Invalid field pick. Allowed field: #{build_attributes}"
    end

    def build_fields
      fields.each do |field|
        target = @presenter.respond_to?(field) ? @presenter : @presenter.object
        @presenter.data[field] = target.send(field) if target
      end
    end
end
