# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#demodulize' do
      it 'handles three modules' do
        _('String::Inflections::Blah'.demodulize).must_equal 'Blah'
      end

      it 'handles two modules' do
        _('String::Inflections'.demodulize).must_equal 'Inflections'
      end

      it 'handles a single module' do
        _('String'.demodulize).must_equal 'String'
      end
    end
    # /#demodulize
  end
end
