# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#underscore' do
      it 'adds underscores between Camelcased words and changes to lowercase' do
        _('EggAndHams'.underscore).must_equal 'egg_and_hams'
        _('EGGAndHams'.underscore).must_equal 'egg_and_hams'
      end

      it 'changes "::" to "/" and changes to lowercase' do
        _('Egg::And::Hams'.underscore).must_equal 'egg/and/hams'
      end

      it 'keeps lowercase words lowercase' do
        _('post'.underscore).must_equal 'post'
      end

      it 'changes "-" to "_"' do
        _('post-id'.underscore).must_equal 'post_id'
      end
    end
    # /#underscore
  end
end
