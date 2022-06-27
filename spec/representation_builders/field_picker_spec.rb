require 'rails_helper'

RSpec.describe FieldPicker do
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:params) { { fields: 'id,title,subtitle' } }
  let(:presenter) { BookPresenter.new(rails_tutorial, params) }
  let(:field_picker) { FieldPicker.new(presenter) }

  before do
    allow(BasePresenter).to receive(:build_attributes).and_return(['id', 'title', 'author_id'])
  end

  describe '#pick' do
    context 'with the fields parameter containing "id,title,subtitle"' do
      it 'updates the presenter "data" with the book "id" and "title"' do
        expect(field_picker.pick.data).to eq({
          'id' => rails_tutorial.id,
          'title' => "Ruby on Rails Tutorial"
        })
      end
    end

    context 'with overriding method defined in presenter' do
      before do
        presenter.class.send(:define_method, :title) { 'Overridden!' }
      end

      it 'updates the presenter "data" with title "Overridden!"' do
        expect(field_picker.pick.data).to eq({
          'id' => rails_tutorial.id,
          'title' => 'Overridden!'
        })
      end

      after do
        presenter.class.send(:remove_method, :title)
      end
    end

    context 'with no fields parameter' do
      let(:params) { {} }

      it 'updates "data" with the fields "id", "title", "author_id"' do
        expect(field_picker.pick.data).to eq({
          'id' => rails_tutorial.id,
          'title' => "Ruby on Rails Tutorial",
          'author_id' => rails_tutorial.author.id
        })
      end
    end
  end
end
