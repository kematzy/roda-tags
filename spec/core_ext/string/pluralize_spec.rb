# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#pluralize' do
      it 'transforms words from singular to plural' do
        _('post'.pluralize).must_equal 'posts'
        _('octopus'.pluralize).must_equal 'octopuses'
      end

      it 'pluralizes the last word in a sentence' do
        _('the blue mailman'.pluralize).must_equal 'the blue mailmen'
        _('the dog and the cat'.pluralize).must_equal 'the dog and the cats'
      end

      it 'pluralizes CamelCased words' do
        _('CamelOctopus'.pluralize).must_equal 'CamelOctopuses'
      end
    end
    # /#pluralize
  end
end
