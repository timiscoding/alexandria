# app/controllers/books_controller.rb
class BooksController < ApplicationController

  def index
    render json: { data: Book.all }
  end

end
