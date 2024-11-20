# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'CoreExt - core_ext/blank' do
  describe '#blank?' do
    describe Numeric do
      it 'responds to :blank?' do
        _(Numeric).must_respond_to(:blank?)
        _(1).must_respond_to(:blank?)
      end

      it 'never returns true' do
        _(1.blank?).must_equal false
        _('100923'.to_i.blank?).must_equal false
      end
    end
    # / Numeric
  end
end
