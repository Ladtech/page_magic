# frozen_string_literal: true

RSpec.describe PageMagic::Utils::String do
  describe '.classify' do
    context 'when parameter is symbol' do
      it 'returns a string' do
        expect(described_class.classify(:Symbol)).to eq('Symbol')
      end
    end

    context 'when parameter is string' do
      it 'returns a string' do
        expect(described_class.classify(:String)).to eq('String')
      end
    end

    context 'when the first letter is lower case' do
      it 'converts the first letter to uppercase' do
        expect(described_class.classify(:symbol)).to eq('Symbol')
      end
    end

    context 'when parameter is in snakecase' do
      it 'removes underscores and capitalises each word' do
        expect(described_class.classify(:snake_case)).to eq('SnakeCase')
      end
    end
  end
end
