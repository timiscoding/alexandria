# app/controllers/books_controller.rb
class BooksController < ApplicationController

  def index
    data = paginate(Book.all).map do |book|
      FieldPicker.new(BookPresenter.new(book, params)).pick
    end

    render json: { data: data }.to_json
  end

end
