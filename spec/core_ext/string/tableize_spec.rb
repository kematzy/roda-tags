# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#tableize' do
      it 'transforms ClassNames to table names' do
        _('BlogPost'.tableize).must_equal 'blog_posts'
        _('user'.tableize).must_equal 'users'
      end

      it 'tableizes underscored words' do
        _('apartment_block'.tableize).must_equal 'apartment_blocks'
      end

      it 'tableizes CamelCased words' do
        _('blogCategory'.tableize).must_equal 'blog_categories'
      end
    end
    # /#tableize
  end
end
