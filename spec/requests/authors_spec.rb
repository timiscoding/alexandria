require 'rails_helper'

RSpec.describe 'Authors', type: :request do
  let(:pat) { create(:author) }
  let(:michael) { create(:michael_hartl) }
  let(:sam) { create(:sam_ruby) }
  let(:authors) { [pat, michael, sam] }

  describe 'GET /api/authors' do
    before do
      authors
      get '/api/authors'
    end

    context 'default behaviour' do
      it 'gets HTTP status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'receives a json with a "data" root key' do
        expect(json_body['data']).not_to be_nil
      end

      it 'receives all 3 authors' do
        expect(json_body['data'].count).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get '/api/authors?fields=given_name,family_name'}
        it 'gets the authors with only with only "given_name" and "family_name"' do
          json_body['data'].each do |author|
            expect(author.keys).to eq(['given_name', 'family_name'])
          end
        end
      end

      context 'without the fields parameter' do
        before { get '/api/authors'}
        it 'gets the authors with all fields' do
          json_body['data'].each do |author|
            expect(author.keys).to eq(['id', 'given_name', 'family_name', 'created_at', 'updated_at'])
          end
        end
      end

      context 'with invalid field name "fid"' do
        before { get '/api/authors?fields=fid'}
        it 'gets HTTP status 400' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'receives error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'receives "fields=fid" as invalid params' do
          expect(json_body['error']['invalid_params']).to eq "fields=fid"
        end
      end
    end

    describe 'pagination' do
      context 'when asking for first page' do
        before { get '/api/authors?page=1&per=2'}

        it 'gets HTTP status 200 ' do
          expect(response).to have_http_status(:ok)
        end

        it 'receives 2 authors back' do
          expect(json_body['data'].size).to eq(2)
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(',').first).to eq '<http://www.example.com/api/authors?page=2&per=2>; rel="next"'
        end
      end

      context 'when asking for second page' do
        before { get '/api/authors?page=2&per=1'}

        it 'gets HTTP status 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'gets 1 author back' do
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        before { get '/api/authors?page=invalid&per=1'}

        it 'gets HTTP status 400' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'gets error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'gets "page=invalid" as invalid parameter' do
          expect(json_body['error']['invalid_params']).to eq "page=invalid"
        end
      end

    end

    describe 'sorting' do
      context 'with valid column name "id"' do
        before { get '/api/authors?sort=id&dir=asc' }

        it 'sorts the authors by id' do
          expect(json_body['data'].first['id']).to be pat.id
          expect(json_body['data'].last['id']).to be sam.id
        end
      end

      context 'with invalid column name "fid"' do
        before { get '/api/authors?sort=fid&dir=desc' }

        it 'gets HTTP status 400' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'receives an error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'receives invalid_params with "sort=fid"' do
          expect(json_body['error']['invalid_params']).to eq "sort=fid"
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering param "q[given_name_cont]=Pat"' do
        before { get '/api/authors?q[given_name_cont]=Pat' }

        it 'gets the author Pat Shaughnessy back' do
          expect(json_body['data'].first['id']).to be pat.id
        end
      end

      context 'with invalid filtering param "q[fgiven_name_cont]=Pat"' do
        before { get '/api/authors?q[fgiven_name_cont]=Pat' }

        it 'gets HTTP status 400' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'receives an error' do
          expect(json_body['error']).not_to be_nil
        end

        it 'receives "q[fgiven_name_cont]=Pat" as invalid param' do
          expect(json_body['error']['invalid_params']).to eq "q[fgiven_name_cont]=Pat"
        end
      end
    end

    describe 'GET /api/authors/:id' do
      context 'with existing resource' do
        before { get '/api/authors/1' }

        it 'gets HTTP status 200' do
          puts authors.inspect
          expect(response).to have_http_status(:ok)
        end

        it 'gets author "Pat" as json' do
          expected = { data: AuthorPresenter.new(pat, {}).fields.embeds }

          expect(response.body).to eq expected.to_json
        end
      end

      context 'with non existant resource' do
        before { get '/api/authors/284981' }

        it 'gets HTTP status 404' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
