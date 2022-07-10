require 'rails_helper'

RSpec.describe Filter do
  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }
  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  let(:scope) { Book.all }
  let(:params) { {} }
  let(:filter) { Filter.new(scope, params) }
  let(:filtered) { filter.filter }

  before do
    allow(BookPresenter).to receive(:filter_attributes).and_return(['id', 'title', 'released_on'])
    books
  end

  describe '#filter' do
    context 'without parameters' do
      it 'returns the scope unchanged' do
        expect(filtered).to eq scope
      end
    end

    context 'with valid parameters' do
      context 'with title_eq=Ruby Under a Microscope"' do
        let(:params) { { 'q' => { 'title_eq' => 'Ruby Under a Microscope' } } }

        it 'gets only Ruby Under a Microscope back' do
          expect(filtered.first.id).to eq ruby_microscope.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with title_cont=Under' do
        let(:params) { { 'q' => { 'title_cont' => 'Under' } } }

        it 'gets only "Ruby Under a Microscope back' do
          expect(filtered.first.id).to eq ruby_microscope.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with "title_notcont=Ruby"' do
        let(:params) { { 'q' => { 'title_notcont' => 'Ruby' } } }

        it 'gets only "Agile Web Development with Rails 4" back' do
          expect(filtered.first.id).to eq agile_web_dev.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with "title_start=Ruby"' do
        let(:params) { { 'q' => { 'title_start' => 'Ruby' } } }

        it 'gets only "Ruby Microscope and Ruby on Rails Tutorial" back' do
          expect(filtered.size).to eq 2
        end
      end

      context 'with "title_end=Tutorial"' do
        let(:params) { { 'q' => { 'title_end' => 'Tutorial' } } }

        it 'gets only "Ruby on Rails Tutorial" back' do
          expect(filtered.first).to eq rails_tutorial
        end
      end

      context 'with "released_on_lt=2013-05-10"' do
        let(:params) { { 'q' => { 'released_on_lt' => '2013-05-10' } } }

        it 'gets only the book with released_on before 2013-05-10' do
          expect(filtered.first.title).to eq rails_tutorial.title
          expect(filtered.size).to eq 1
        end
      end

      context 'with "released_on_gt=2013-01-01"' do
        let(:params) { { 'q' => { 'released_on_gt' => '2014-01-01' } } }

        it 'gets only the book with id 1' do
          expect(filtered.first.title).to eq agile_web_dev.title
          expect(filtered.size).to eq 1
        end
      end
    end

    context 'with invalid parameters' do
      context 'with invalid column name "fid"' do
        let(:params) { { 'q' => { 'fid_gt' => '2' } } }

        it 'raises a "QueryBuilderError" exception' do
          expect { filtered }.to raise_error(QueryBuilderError)
        end
      end

      context 'with invalid predicate name "gtz"' do
        let(:params) { { 'q' => { 'id_gtz' => '2' } } }

        it 'raises a "QueryBuilderError" exception' do
          expect { filtered }.to raise_error(QueryBuilderError)
        end
      end
    end
  end
end
