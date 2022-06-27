require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }

  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  describe 'GET api/books' do
    before { books }

    context 'default behaviour' do
      before { get '/api/books' }

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives a json with the "data" root key' do
        expect(json_body['data']).to_not be nil
      end

      it 'receives all 3 books' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get "/api/books?fields=id,title,author_id" }

        it 'gets the books with only the "id", "title" and "author_id"' do
          json_body['data'].each do |book|
            expect(book.keys).to eq(['id', 'title', 'author_id'])
          end
        end
      end

      context 'without the "fields" parameter' do
        before { get "/api/books" }

        it 'gets books with all fields specified in the presenter' do
          json_body['data'].each do |book|
            expect(book.keys).to eq(BookPresenter.build_attributes.map(&:to_s))
          end
        end
      end
    end
  end
end
