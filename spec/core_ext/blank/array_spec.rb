# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'CoreExt - core_ext/blank' do
  describe '#blank?' do
    describe Array do
      it 'responds to :blank?' do
        _(Array).must_respond_to(:blank?)
        _([]).must_respond_to(:blank?)
      end

      describe 'returns true' do
        it 'when empty' do
          _([].blank?).must_equal true
        end
      end

      describe 'returns false' do
        it 'when not nil or empty' do
          _(['value'].blank?).must_equal false
        end
      end
    end
    # / Array
  end
end
