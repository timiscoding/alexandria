module PgSearch
  class DocumentPresenter < BasePresenter
    related_to :searchable
    build_with :content, :searchable_id, :searchable_type, :resource_url

    def resource_url
      polymorphic_url(object.searchable)
    end
  end
end
