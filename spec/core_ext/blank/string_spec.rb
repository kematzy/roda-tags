# frozen_string_literal: true

require_relative '../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'CoreExt - core_ext/blank' do
  describe '#blank?' do
    describe String do
      it 'responds to :blank?' do
        _(String).must_respond_to(:blank?)
      end

      describe 'returns true' do
        it 'if empty' do
          _(''.blank?).must_equal true
        end

        it 'if contains whitespace(s) only' do
          _(' '.blank?).must_equal true
          _('    '.blank?).must_equal true
        end

        it 'if contains "\r, \n, \t" characters' do
          _(" \r".blank?).must_equal true
          _(" \n".blank?).must_equal true
          _(" \t".blank?).must_equal true
        end
      end

      describe 'returns false' do
        it 'if it is not empty' do
          _('not blank'.blank?).must_equal false
        end
      end
    end
    # / String
  end
end
# rubocop:enable Metrics/BlockLength
