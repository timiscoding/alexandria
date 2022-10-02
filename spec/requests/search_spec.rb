require 'rails_helper'

RSpec.describe 'Search', type: :request do
  let(:ruby_microscope) { create(:book) }
  let(:ruby_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }
  let(:books)  { [ruby_microscope, ruby_tutorial, agile_web_dev] }

  describe 'GET /api/search/:text' do
    before do
      books
    end

    context "with text = ruby" do
      before do
        get '/api/search/ruby'
      end

      it 'gets HTTP status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'receives a "ruby_microscope" document' do
        puts json_body
        expect(json_body['data'][0]['searchable_id']).to eq ruby_microscope.id
        expect(json_body['data'][0]['searchable_type']).to  eq 'Book'
      end

      it 'receives a "ruby_tutorial" document' do
        expect(json_body['data'][1]['searchable_id']).to eq ruby_tutorial.id
        expect(json_body['data'][1]['searchable_type']).to  eq 'Book'
      end

      it 'receives a "sam ruby" document' do
        expect(json_body['data'][2]['searchable_id']).to eq agile_web_dev.author.id
        expect(json_body['data'][2]['searchable_type']).to  eq 'Author'
      end
    end

  end
end
