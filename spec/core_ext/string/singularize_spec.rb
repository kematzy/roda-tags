# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#singularize' do
      it 'transforms words from plural to singular' do
        _('posts'.singularize).must_equal 'post'
        _('octopuses'.singularize).must_equal 'octopus'
      end

      it 'singularizes the last word in a sentence' do
        _('the blue mailmen'.singularize).must_equal 'the blue mailman'
        _('the dogs and the cats'.singularize).must_equal 'the dogs and the cat'
      end

      it 'singularizes CamelCased words' do
        _('CamelOctopuses'.singularize).must_equal 'CamelOctopus'
      end
    end
    # /#singularize
  end
end
