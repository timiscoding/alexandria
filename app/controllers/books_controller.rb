# app/controllers/books_controller.rb
class BooksController < ApplicationController

  def index
    books = orchestrate_query(Book.all)

    render serialize(books)
  end

  def show
    render serialize(book)
  end

  def create
    if book.save
      render serialize(book).merge(status: :created, location: book)
    else
      unprocessable_entity!(book)
    end
  end

  def update
    if book.update(book_params)
      render serialize(book).merge(status: :ok)
    else
      unprocessable_entity!(book)
    end
  end

  def destroy
    book.destroy
    render status: :no_content
  end

  private

  def book
    @book ||= params[:id] ? Book.find_by!(id: params[:id]) : Book.new(book_params)
  end
  alias_method :resource, :book

  def book_params
    params.require(:data).permit(:title, :author, :subtitle, :isbn_10, :isbn_13, :description,
                                 :released_on, :publisher_id, :author_id, :cover)
  end

end
