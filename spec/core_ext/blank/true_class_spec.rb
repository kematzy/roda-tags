# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'CoreExt - core_ext/blank' do
  describe '#blank?' do
    describe TrueClass do
      it 'responds to :blank?' do
        _(TrueClass).must_respond_to(:blank?)
      end

      it 'always return true' do
        _(false.blank?).must_equal true
      end
    end
    # / TrueClass
  end
end
