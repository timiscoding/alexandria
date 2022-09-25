require 'rails_helper'

RSpec.describe 'Publishers', type: :request do
  let(:oreilly) { create(:publisher) }
  let(:dev_media) { create(:dev_media) }
  let(:super_books) { create(:super_books) }
  let!(:publishers) { [oreilly, dev_media, super_books] }

  describe 'GET /api/publishers' do
    context 'default behaviour' do
      before { get '/api/publishers' }

      it 'gets HTTP status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'receives json with data key' do
        expect(json_body['data']).not_to be_nil
      end

      it 'receives all 3 publishers' do
        puts json_body
        expect(json_body['data'].size).to eq 3
      end
    end

    context 'field picking' do
      context 'with the fields parameter' do
        before do
          get '/api/publishers?fields=name'
        end

        it 'gets the publishers with only "name"' do
          json_body['data'].each do |p|
            expect(p.keys).to eq ['name']
          end
        end
      end

      context 'without the field parameter' do
        before do
          get '/api/publishers'
        end

        it 'gets the publishers with all fields' do
          json_body['data'].each do |p|
            expect(p.keys).to eq PublisherPresenter.build_attributes.map(&:to_s)
          end
        end
      end

      context 'with invalid fieldn name "fid"' do
        before do
          get '/api/publishers?fields=fid'
        end

        it 'gets HTTP status 400' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'receives json with "error"' do
          expect(json_body['error']).to_not be_nil
        end

        it 'receives invalid_params with fields=fid' do
          expect(json_body['error']['invalid_params']).to eq "fields=fid"
        end
      end
    end
  end
end
