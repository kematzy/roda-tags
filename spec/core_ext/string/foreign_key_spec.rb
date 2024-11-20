# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#foreign_key' do
      it 'transforms class names to foreign_key' do
        _('Message'.foreign_key).must_equal 'message_id'
        _('User'.foreign_key).must_equal 'user_id'
      end

      it 'transforms underscored names' do
        _('Apartment_Block'.foreign_key).must_equal 'apartment_block_id'
      end

      it 'transforms without _ when passed "use_underscore: false"' do
        _('Message'.foreign_key(use_underscore: false)).must_equal 'messageid'
      end

      it 'foreign_keys CamelCased words' do
        _('BlogCategory'.foreign_key).must_equal 'blog_category_id'
      end

      it 'foreign_keys Blog::Category' do
        _('Blog::Category'.foreign_key).must_equal 'category_id'
      end
    end
    # /#foreign_key
  end
end
