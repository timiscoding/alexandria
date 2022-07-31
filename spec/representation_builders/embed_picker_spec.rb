require 'rails_helper'

RSpec.describe 'EmbedPicker' do
  let(:author) { create(:michael_hartl) }
  let(:ruby_microscope) { create(:ruby_microscope, author_id: author.id) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial, author_id: author.id) }

  let(:params) { { } }
  let(:embed_picker) { EmbedPicker.new(presenter) }

  describe '#embed' do
    let(:presenter) { BookPresenter.new(rails_tutorial, params) }

    before do
      allow(BookPresenter).to receive(:relations).and_return(['author'])
    end

    context 'with no embed parameter' do
      it 'returns the "data" hash without changing it' do
        expect(embed_picker.embed.data).to eq presenter.data
      end
    end

    context 'with invalid relation "something"' do
      let(:params) { { embed: 'something' } }

      it 'raises error' do
        expect { embed_picker.embed }.to raise_error(RepresentationBuilderError)
      end
    end

    context 'with the valid "embed" parameter containing "author"' do
      let(:params) { { embed: 'author' } }

      it 'embeds the "author" data' do
        expect(embed_picker.embed.data[:author]).to eq({
          'id' => rails_tutorial.author.id,
          'given_name' => "Michael",
          'family_name' => "Hartl",
          'created_at' => rails_tutorial.author.created_at,
          'updated_at' => rails_tutorial.author.updated_at
        })
      end
    end

    context 'with the embed parameter containing "books"' do
      let(:params) { { embed: 'books' } }
      let(:presenter) { AuthorPresenter.new(author, params) }

      before do
        allow(AuthorPresenter).to receive(:relations).and_return(['books'])
        ruby_microscope && rails_tutorial
      end

      it 'embeds the data "books"' do
        expect(embed_picker.embed.data['books'].size).to eq 2
        expect(embed_picker.embed.data['books'].first['id']).to eq ruby_microscope.id
        expect(embed_picker.embed.data['books'].second['id']).to eq rails_tutorial.id
      end
    end
  end
end
