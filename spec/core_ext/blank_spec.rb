require_relative '../spec_helper'


class CoreExtBlankSpec < Minitest::Spec

  describe 'CoreExt' do

    describe '"core_ext/blank"' do
      require_relative '../../lib/core_ext/blank'

      class EmptyTrue
        def empty?; 0; end
      end

      class EmptyFalse
        def empty?; nil; end
      end

      BLANK = [ EmptyTrue.new, nil, false, '', '   ', "  \n\t  \r ", '　', "\u00a0", [], {} ]
      NOT   = [ EmptyFalse.new, Object.new, true, 0, 1, 'a', [nil], { nil => 0 } ]


      def test_presence
        BLANK.each { |v| assert_nil v.presence, "#{v.inspect}.presence should return nil" }
        NOT.each   { |v| assert_equal v,   v.presence, "#{v.inspect}.presence should return self" }
      end

      describe Object do

        describe "should respond to" do

          it "#blank?" do
            _(Object).must_respond_to(:blank?)
            _(Object.new).must_respond_to(:blank?)
          end

          it "#present?" do
            _(Object).must_respond_to(:present?)
            _(Object.new).must_respond_to(:present?)
          end

          it "#presence" do
            _(Object).must_respond_to(:presence)
            _(Object.new).must_respond_to(:presence)
          end

        end

        describe "#blank?" do

          it "should return false for Object.new" do
            _(Object.new.blank?).must_equal false
          end

          it "should return true when given an Object whose :empty? method returns true" do
            obj = EmptyTrue.new
            _(obj.blank?).must_equal true
          end

          it "should return false when given an Object whose :empty? method returns false" do
            obj = EmptyFalse.new
            _(obj.blank?).must_equal false
          end

        end #/the :blank? method

        describe "#present?" do

          NOT.each do |v|
            it "#present? should return true for '#{v.inspect}'" do
              _(v.present?).must_equal true
            end
          end

          BLANK.each do |v|
            it "should return false for '#{v.inspect}'" do
              _(v.present?).must_equal false
            end
          end

        end #/ #present?

        describe "#presence" do

          NOT.each do |v|
            it "#presence should return the receiver for '#{v.inspect}'" do
              _(v.presence).must_equal v
            end
          end

          BLANK.each do |v|
            it "#presence should return nil for '#{v.inspect}'" do
              _(v.presence).must_be_nil
            end
          end

        end #/ #presence

      end #/ Object


      describe String do

        it "should respond to :blank?" do
          _(String).must_respond_to(:blank?)
        end

        it "should be blank if empty" do
          _(''.blank?).must_equal true
        end

        it 'should be blank if it only contains whitespace' do
          _(' '.blank?).must_equal true
          _(" \r \n \t ".blank?).must_equal true
        end

        it 'should not be blank if it contains non-whitespace' do
          _('not blank'.blank?).must_equal false
        end

      end #/ String

      describe NilClass do

        it "should respond to :blank?" do
          _(NilClass).must_respond_to(:blank?)
        end

        it "should always be blank" do
          _(nil.blank?).must_equal true # nil should return true, not false
        end

      end #/ NilClass

      describe FalseClass do

        it "should respond to :blank?" do
          _(FalseClass).must_respond_to(:blank?)
        end

        it "should always be blank" do
          _(false.blank?).must_equal true
        end

      end #/ FalseClass

      describe TrueClass do

        it "should respond to :blank?" do
          _(TrueClass).must_respond_to(:blank?)
        end

        it "should never be blank" do
          _(true.blank?).must_equal false
        end

      end #/ TrueClass


      describe Array do

        it "should respond to :blank?" do
          _(Array).must_respond_to(:blank?)
          _([]).must_respond_to(:blank?)
        end

        it "should be blank when empty" do
          _([].blank?).must_equal true
        end

        it "should NOT be blank if not nil or empty" do
          _(['value'].blank?).must_equal false
        end

      end #/ Array

      describe Hash do

        it "should respond to :blank?" do
          _(Hash).must_respond_to(:blank?)
          _({}).must_respond_to(:blank?)
        end

        it "should be blank when empty" do
          _({}.blank?).must_equal true
        end

        it "should NOT be blank if not nil or empty" do
          _({:a => :b}.blank?).must_equal false
        end

      end #/ Hash

      describe Numeric do

        it "should respond to :blank?" do
          _(Numeric).must_respond_to(:blank?)
          _(1).must_respond_to(:blank?)
        end

        it "should never be blank" do
          _(1.blank?).must_equal false
          _("100923".to_i.blank?).must_equal false
        end

      end #/ Numeric

      describe Time do

        it "should respond to :blank?" do
          _(Time).must_respond_to(:blank?)
          _(Time.now).must_respond_to(:blank?)
        end

        it "should never be blank" do
          _(Time.now.blank?).must_equal false
        end

      end #/ Time

    end

  end

end
