# frozen_string_literal: true

require_relative '../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'CoreExt - core_ext/hash' do
  describe Hash do
    describe 'Hash does not respond to' do
      %i[reverse_merge reverse_merge! reverse_update].each do |m|
        it "##{m}" do
          _(Hash).wont_respond_to(m.to_sym)
        end
      end
    end

    describe '{} does not respond to' do
      %i[reverse_merge reverse_merge! reverse_update].each do |m|
        it "##{m}" do
          _({}).must_respond_to(m.to_sym)
        end
      end
    end

    describe 'reverse_merge*' do
      before(:each) do
        @defaults = { a: 'x', b: 'y', c: 10 }.freeze
        @options  = { a: 1, b: 2 }
        @expected = { a: 1, b: 2, c: 10 }
      end

      describe '#reverse_merge' do
        it 'creates a new hash by merging @defaults into @options' do
          _(@options.reverse_merge(@defaults)).must_equal @expected
          _(@expected).wont_equal @options
        end
      end
      # / #reverse_merge

      describe '#reverse_merge!' do
        it 'replaces values in Hash by merging @defaults into @options' do
          merged = @options.dup
          _(merged.reverse_merge!(@defaults)).must_equal @expected
          _(merged).must_equal @expected
        end
      end
      # / #reverse_merge!

      describe '#reverse_update (alias #reverse_merge!)' do
        it 'replaces values in Hash by merging @defaults into @options' do
          merged = @options.dup
          _(merged.reverse_update(@defaults)).must_equal @expected
          _(merged).must_equal @expected
        end
      end
      # / #reverse_update
    end
  end
  # /Hash
end
# rubocop:enable Metrics/BlockLength
