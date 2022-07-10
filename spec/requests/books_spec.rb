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

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get '/api/books?page=1&per=2' }
        it 'receives HTTP status 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'receives only two books' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(',').first).to eq '<http://www.example.com/api/books?page=2&per=2>; rel="next"'
        end
      end

      context 'when asking for the second page' do
        before { get '/api/books?page=2&per=2' }

        it 'receives HTTP status 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'receives only one book' do
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        before { get '/api/books?page=invalid&per=10'}

        it 'receives HTTP status 400' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'receives an error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'receives page=fake as invalid parameter' do
          expect(json_body['error']['invalid_params']).to eq 'page=invalid'
        end
      end
    end

    describe 'sorting' do
      context 'with valid column name "id"' do
        it 'sorts the books by id descending' do
          get '/api/books?sort=id&dir=desc'

          expect(json_body['data'].first['id']).to eq agile_web_dev.id
          expect(json_body['data'].last['id']).to eq ruby_microscope.id
        end
      end

      context 'with invalid column name "fid"' do
        before { get '/api/books?sort=fid&dir=desc' }

        it 'gets "400 bad request" back' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'receives an error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'receives "sort=fid" as invalid param' do
          expect(json_body['error']['invalid_params']).to eq "sort=fid"
        end
      end
    end

    describe 'filtering' do
      context 'with valid parameter "q[title_cont]=Microscope"' do
        it 'receives "Ruby under a micrscope back" back' do
          get '/api/books?q[title_cont]=Microscope'
          expect(json_body['data'].first['id']).to eq(ruby_microscope.id)
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'with invalid parameter "q[ftitle_cont]=Microscope"' do
        before { get '/api/books?q[ftitle_cont]=Microscope' }

        it 'gets "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not eq nil
        end

        it 'receives "q[ftitle]=Microsope" as an invalid parameter' do
          expect(json_body['error']['invalid_params']).to eq "q[ftitle_cont]=Microscope"
        end
      end
    end
  end
end
