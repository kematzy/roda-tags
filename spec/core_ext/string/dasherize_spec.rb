# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#dasherize' do
      it 'transform underscores to dashes' do
        _('egg_and_hams'.dasherize).must_equal 'egg-and-hams'
      end

      it 'does not transform words with spaces' do
        _('blog post'.dasherize).must_equal 'blog post'
      end

      it 'does not transform words without underscores' do
        _('post'.dasherize).must_equal 'post'
      end
    end
    # /#dasherize
  end
end
