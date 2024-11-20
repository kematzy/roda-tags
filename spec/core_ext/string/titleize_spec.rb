# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#titleize' do
      it 'removes dashes and capitalize' do
        _('egg-and: hams'.titleize).must_equal 'Egg And: Hams'
      end

      it 'converts "post" to "Post"' do
        _('post'.titleize).must_equal 'Post'
      end

      it 'removes _id and capitalize' do
        _('post_id'.titleize).must_equal 'Post'
      end
    end
    # /#titleize

    describe '#titlecase' do
      it 'removes dashes and capitalize' do
        _('egg-and: hams'.titlecase).must_equal 'Egg And: Hams'
      end

      it 'converts "post" to "Post"' do
        _('post'.titlecase).must_equal 'Post'
      end

      it 'removes _id and capitalize' do
        _('post_id'.titlecase).must_equal 'Post'
      end
    end
    # /#titlecase
  end
end
