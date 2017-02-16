module PageMagic
  class Element
    describe QueryBuilder do
      it 'has a predefined query for each element type' do
        missing = PageMagic::Elements::TYPES.dup.delete_if { |type| type.to_s.end_with?('s') }.find_all do |type|
          described_class.constants.include?(type)
        end
        expect(missing).to be_empty
      end

      describe '.find' do
        it 'finds the constant with the given name' do
          expect(described_class.find(:button)).to be(described_class::BUTTON)
        end

        context 'constant not found' do
          it 'returns a default' do
            expect(described_class.find(:billy)).to be(described_class::ELEMENT)
          end
        end
      end

      describe '#build' do
        let(:selector) { Selector.new }
        before do
          expect(Selector).to receive(:find).with(:css).and_return(selector)
        end
        let(:locator) { { css: '.css' } }

        it 'builds a query using the correct selector' do
          expected = Query.new(locator.values)
          expect(subject.build(locator)).to eq(expected)
        end

        it 'adds options to the result' do
          expected = Query.new(locator.values.concat([:options]))
          expect(subject.build(locator, :options)).to eq(expected)
        end

        context 'selector support element type' do
          subject do
            described_class.new(:field)
          end

          it 'passes element type through to the selector' do
            expect(selector).to receive(:build).with(:field, '.css').and_call_original
            subject.build(locator)
          end
        end
      end
    end

    class QueryBuilder
      describe BUTTON do
        it 'has an element type' do
          expect(described_class.type).to eq(:button)
        end
      end

      describe ELEMENT do
        it ' does not has an element type' do
          expect(described_class.type).to be_nil
        end
      end

      describe LINK do
        it 'has an element type' do
          expect(described_class.type).to eq(:link)
        end
      end

      describe TEXT_FIELD do
        it 'has an element type' do
          expect(described_class.type).to eq(:field)
        end

        it 'the same as all form field types' do
          expect(described_class).to eq(CHECKBOX).and eq(SELECT_LIST).and eq(RADIO).and eq(TEXTAREA)
        end
      end
    end

    context 'integration' do
      include_context :webapp_fixture
      let(:capybara_session) { Capybara::Session.new(:rack_test, rack_app).tap { |s| s.visit('/elements') } }

      it 'finds fields' do
        query = QueryBuilder.find(:text_field).build(name: 'field_name')
        expect(query.execute(capybara_session).tag_name).to eq('input')
      end

      it 'finds buttons' do
        query = QueryBuilder.find(:button).build(text: 'a button')
        expect(query.execute(capybara_session).tag_name).to eq('button')
      end

      it 'finds links' do
        query = QueryBuilder.find(:link).build(text: 'a link')
        expect(query.execute(capybara_session).tag_name).to eq('a')
      end

      it 'finds elements' do
        query = QueryBuilder.find(:element).build(name: 'field_name')
        expect(query.execute(capybara_session).tag_name).to eq('input')
      end
    end
  end
end
