# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'CoreExt - core_ext/blank' do
  describe '#blank?' do
    describe NilClass do
      it 'responds to :blank?' do
        _(NilClass).must_respond_to(:blank?)
      end

      it 'is always be blank' do
        _(nil.blank?).must_equal true # nil should return true, not false
      end
    end
    # / NilClass
  end
end
