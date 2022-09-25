class PublishersController < ApplicationController

  def index
    publishers = orchestrate_query(Publisher.all)
    render serialize(publishers)
  end

  def show
    render serialize(publisher)
  end

  def create
    publisher = Publisher.new(publisher_params)

    if publisher.save
      render serialize(publisher).merge(status: :created, location: publisher)
    else
      unprocessable_entity!(publisher)
    end
  end

  def update
    if publisher.update(publisher_params)
      render serialize(publisher).merge(status: :ok)
    else
      unprocessable_entity!(publisher)
    end
  end

  def destroy
    publisher.destroy
    render status: :no_content
  end

  private

  def publisher
    @publisher ||= params[:id] ? Publisher.find_by!(id: params[:id]) :
                                 Publisher.new(publisher_params)
  end
  alias_method :resource, :publisher

  def publisher_params
    params.require(:data).permit(:name)
  end

end
