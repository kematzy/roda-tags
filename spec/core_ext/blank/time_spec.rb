# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'CoreExt - core_ext/blank' do
  describe '#blank?' do
    describe Time do
      it 'responds to :blank?' do
        _(Time).must_respond_to(:blank?)
        _(Time.now).must_respond_to(:blank?)
      end

      it 'never returns true' do
        _(Time.now.blank?).must_equal false
      end
    end
    # / Time
  end
end
