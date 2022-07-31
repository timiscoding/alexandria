# app/controllers/books_controller.rb
class BooksController < ApplicationController

  def index
    books = orchestrate_query(Book.all)
    serializer = Alexandria::Serializer.new(data: books,
                                            params: params,
                                            actions: [:embeds, :fields])

    render json: serializer.to_json
  end

end
