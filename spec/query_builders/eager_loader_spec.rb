require 'rails_helper.rb'

RSpec.describe EagerLoader do
  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }
  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  let(:scope) { double('author', model: Author ) }
  let(:params) { {} }
  let(:eager_loader) { EagerLoader.new(scope, params) }
  let(:eager_loaded) { eager_loader.load }

  before do
    allow(AuthorPresenter).to receive(:relations).and_return(['books'])
    books
  end

  describe '#load' do
    context 'without parameters' do
      it 'returns the scope unchanged' do
        eager_loaded
        expect(scope).not_to receive(:includes)
      end
    end

    context 'with valid parameter embed=books' do
      let(:params) { HashWithIndifferentAccess.new({ 'embed' => 'books' }) }
      it 'receives authors with books' do
        expect(scope).to receive(:includes)
        eager_loaded
      end
    end

    context 'with valid parameter include=books' do
      let(:params) { HashWithIndifferentAccess.new({ 'include' => 'books' }) }
      it 'receives authors with books' do
        expect(scope).to receive(:includes)
        eager_loaded
      end
    end

    context 'with invalid parameter include=fbooks' do
      let(:params) { HashWithIndifferentAccess.new({ 'include' => 'fbooks' }) }
      it 'raises an error' do
        expect { eager_loaded }.to raise_error(QueryBuilderError)
      end
    end
  end

end
