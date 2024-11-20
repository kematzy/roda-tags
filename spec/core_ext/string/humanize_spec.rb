# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#humanize' do
      it 'removes underscores and capitalize' do
        _('egg_and_hams'.humanize).must_equal 'Egg and hams'
      end

      it 'converts "post" to "Post"' do
        _('post'.humanize).must_equal 'Post'
      end

      it 'removes _id and capitalize' do
        _('post_id'.humanize).must_equal 'Post'
      end
    end
    # /#humanize
  end
end
