# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#classify' do
      it 'transforms table names to ClassNames' do
        _('egg_and_hams'.classify).must_equal 'EggAndHam'
        _('user'.classify).must_equal 'User'
        _('blog_posts'.classify).must_equal 'BlogPost'
      end

      it 'transforms underscored names' do
        _('apartment_block'.classify).must_equal 'ApartmentBlock'
      end

      it 'classifys CamelCased words' do
        _('blogCategory'.classify).must_equal 'BlogCategory'
      end
    end
    # /#classify
  end
end
