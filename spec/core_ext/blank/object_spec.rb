# frozen_string_literal: true

require_relative '../../spec_helper'

class EmptyTrue
  def empty?
    0
  end
end

class EmptyFalse
  def empty?
    nil # rubocop:disable Style/ReturnNilInPredicateMethodDefinition
  end
end

BLANK = [
  EmptyTrue.new, nil, false, '', '   ', "  \n\t  \r ", '　', "\u00a0", [], {}
].freeze

NOT = [
  EmptyFalse.new, Object.new, true, 0, 1, 'a', [nil], { nil => 0 }
].freeze

# rubocop:disable Metrics/BlockLength
describe 'CoreExt - core_ext/blank' do
  describe Object do
    describe 'responds to' do
      it '#blank?' do
        _(Object).must_respond_to(:blank?)
        _(Object.new).must_respond_to(:blank?)
      end

      it '#present?' do
        _(Object).must_respond_to(:present?)
        _(Object.new).must_respond_to(:present?)
      end

      it '#presence' do
        _(Object).must_respond_to(:presence)
        _(Object.new).must_respond_to(:presence)
      end
    end
    # /responds to

    describe '#blank?' do
      describe 'returns true' do
        it 'when given an Object whose :empty? method returns true' do
          obj = EmptyTrue.new
          _(obj.blank?).must_equal true
        end
      end

      describe 'returns false' do
        it 'for Object.new' do
          _(Object.new.blank?).must_equal false
        end

        it 'when given an Object whose :empty? method returns false' do
          obj = EmptyFalse.new
          _(obj.blank?).must_equal false
        end
      end
    end
    # /#blank?

    describe '#present?' do
      describe 'returns true' do
        NOT.each do |v|
          it "##{v.inspect}" do
            _(v.present?).must_equal true
          end
        end
      end

      describe 'returns false' do
        BLANK.each do |v|
          it "##{v.inspect}" do
            _(v.present?).must_equal false
          end
        end
      end
    end
    # /#present?

    describe '#presence' do
      describe 'returns self from' do
        NOT.each do |v|
          it "##{v.inspect}" do
            _(v.presence).must_equal v
          end
        end
      end

      describe 'returns nil' do
        BLANK.each do |v|
          it "##{v.inspect}" do
            _(v.presence).must_be_nil
          end
        end
      end
    end
    # /#presence
  end
  # /Object
end
# rubocop:enable Metrics/BlockLength
