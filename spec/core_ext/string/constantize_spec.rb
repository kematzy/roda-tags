# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

describe 'CoreExt - core_ext/string' do
  describe String do
    describe '#constantize' do
      it 'converts a "String" to a constant String' do
        _('String'.constantize).must_equal String
      end

      it 'converts a "String::Inflections" to a constant String::Inflections' do
        _('String::Inflections'.constantize).must_equal String::Inflections
      end

      it 'raises NameError on invalid strings' do
        _(proc { 'BKSDDF'.constantize }).must_raise NameError

        _(proc { '++A++'.constantize }).must_raise NameError
      end
    end
    # /#constantize
  end
end
