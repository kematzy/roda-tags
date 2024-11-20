# frozen_string_literal: true

require_relative '../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'CoreExt - core_ext/hash' do
  describe Hash do
    describe '#to_html_attributes' do
      let(:tmp) { { id: 'home', class: 'index' } }

      it 'Hash does not respond to' do
        _(Hash).wont_respond_to(:to_html_attributes)
      end

      it '{} responds to' do
        _({}).must_respond_to(:to_html_attributes)
      end

      it 'outputs all items in the hash' do
        _(tmp.to_html_attributes).must_equal 'class="index" id="home"'
      end

      it 'handles empty Hash values' do
        tmp[:empty] = ''
        _(tmp.to_html_attributes).must_equal 'class="index" empty="" id="home"'
      end

      it 'handles nil Hash values' do
        tmp[:empty] = nil
        _(tmp.to_html_attributes).must_equal 'class="index" empty="" id="home"'
      end

      it 'handles Array Hash values' do
        tmp[:array] = %i[user name]
        _(tmp.to_html_attributes).must_equal('array="user_name" class="index" id="home"')
      end

      it 'removes empty attrs when passed :ignore_empty without modifying the original Hash' do
        tmp[:empty] = nil
        tmp[:empty_string] = ''
        tmp.to_html_attributes(:ignore_empty)

        _(tmp.to_html_attributes(:ignore_empty)).wont_match(/empty_string=""/)
        _(tmp.to_html_attributes(:ignore_empty)).wont_match(/empty=""/)

        _(tmp.to_html_attributes).must_match(/empty_string=""/)
        _(tmp.to_html_attributes).must_match(/empty=""/)
        # _(tmp.to_html_attributes).must_equal 'class="index" empty="" empty_string="" id="home"'
      end
    end
    # / #to_html_attributes
  end
  # / Hash
end
# rubocop:enable Metrics/BlockLength
