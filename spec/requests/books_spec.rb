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

      context 'with invalid field name "fid"' do
        before { get '/api/books?fields=fid,title,author_id' }

        it 'gets 400 status back' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'receives error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'receives "fields=fid" as invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'fields=fid'
        end
      end
    end

    describe 'embed picking' do
      context 'with embed parameter' do
        before { get '/api/books?embed=author' }

        it 'gets the books with their authors embedded' do
          json_body['data'].each do |book|
            expect(book['author'].keys).to eq(
              ['id', 'given_name', 'family_name', 'created_at', 'updated_at']
            )
          end
        end
      end

      context 'with invalid embed parameter' do
        before { get '/api/books?embed=fake,author' }

        it "gets a '400 Bad request' back" do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'receives invalid params' do
          expect(json_body['error']['invalid_params']).to eq('embed=fake')
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

  describe 'GET api/books/:id' do
    context 'with existing resource' do
      before { get "/api/books/#{rails_tutorial.id}" }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'receives the "rails tutorial" book as JSON' do
        expected = { data: BookPresenter.new(rails_tutorial, {}).fields.embeds }

        expect(response.body).to eq(expected.to_json)
      end
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        get '/api/books/483298713'
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST api/books' do
    let(:author) { create(:michael_hartl) }
    before { post '/api/books', params: { data: params } }

    context 'with valid parameters' do
      let(:params) do
        # factorybot method for returning attributes hash that can be used to build a new instance
        # override author_id value
        attributes_for(:ruby_on_rails_tutorial, author_id: author.id)
      end

      it 'gets HTTP status 201' do
        expect(response).to have_http_status(:created)
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['title']).to eq 'Ruby on Rails Tutorial'
      end

      it 'adds a record in the database' do
        expect(Book.count).to eq 1
      end

      it 'gets the new resource location in the Location header' do
        expect(response.headers['Location']).to eq(
          "http://www.example.com/api/books/#{Book.first.id}")
      end
    end

    context 'with invalid parameters' do
      let(:params) { attributes_for(:ruby_on_rails_tutorial, title: '') }

      it 'gets HTTP status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'receives the error details' do
        expect(json_body['error']['invalid_params']).to eq(
           {'author'=>['must exist', "can't be blank"], 'title'=>["can't be blank"]}
        )
      end

      it 'does not add a record to the database' do
        expect(Book.count).to eq 0
      end
    end
  end

  describe 'PATH api/books/:id' do
    before { patch "/api/books/#{rails_tutorial.id}", params: { data: params } }

    context 'with valid parameters' do
      let(:params) { { title: 'The Ruby on Rails Tutorial' } }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'receives the updated resource' do
        expect(json_body['data']['title']).to eq 'The Ruby on Rails Tutorial'
      end

      it 'updates the record in the database' do
        expect(Book.first.title).to eq 'The Ruby on Rails Tutorial'
      end
    end

    context 'with invalid parameters' do
      let(:params) { { title: '' } }

      it 'gets HTTP status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'receives error with invalid params' do
        expect(json_body['error']['invalid_params']).to eq(
          { 'title'=>["can't be blank"] }
        )
      end

      it 'does not update the record in the database' do
        expect(Book.first.title).to eq 'Ruby on Rails Tutorial'
      end
    end
  end

  describe 'DELETE api/books/:id' do
    context 'with existing resource' do
      before { delete "/api/books/#{rails_tutorial.id}" }

      it 'gets HTTP status 204' do
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the book from the database' do
        expect(Book.count).to eq 0
      end
    end

    context 'with nonexistent resource' do
      before { delete "/api/books/4891279" }

      it 'gets HTTP status 404' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
