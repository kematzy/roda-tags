# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#camelize' do
      it 'converts "post" to "Post"' do
        _('post'.camelize).must_equal 'Post'
      end

      it 'converts "egg_and_hams" to "EggAndHams"' do
        _('egg_and_hams'.camelize).must_equal 'EggAndHams'
      end

      it 'converts "egg_and_hams" to "eggAndHams" when passed :false' do
        _('egg_and_hams'.camelize(false)).must_equal 'eggAndHams'
      end
    end
    # /#camelize

    describe '#camelcase (alias #camelize)' do
      it 'converts "post" to "Post"' do
        _('post'.camelcase).must_equal 'Post'
      end

      it 'converts "egg_and_hams" to "EggAndHams"' do
        _('egg_and_hams'.camelcase).must_equal 'EggAndHams'
      end

      it 'converts "egg_and_hams" to "eggAndHams" when passed :false' do
        _('egg_and_hams'.camelcase(false)).must_equal 'eggAndHams'
      end
    end
    # /#camelcase (alias #camelize)
  end
end
