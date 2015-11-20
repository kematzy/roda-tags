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
        BLANK.each { |v| assert_equal nil, v.presence, "#{v.inspect}.presence should return nil" }
        NOT.each   { |v| assert_equal v,   v.presence, "#{v.inspect}.presence should return self" }
      end
      
      describe Object do 
        
        describe "should respond to" do 
          
          it "#blank?" do 
            Object.must_respond_to(:blank?)
            Object.new.must_respond_to(:blank?)
          end
          
          it "#present?" do 
            Object.must_respond_to(:present?)
            Object.new.must_respond_to(:present?)
          end
          
          it "#presence" do 
            Object.must_respond_to(:presence)
            Object.new.must_respond_to(:presence)
          end
          
        end
        
        describe "#blank?" do 
          
          it "should return false for Object.new" do 
            Object.new.blank?.must_equal false
          end
          
          it "should return true when given an Object whose :empty? method returns true" do 
            obj = EmptyTrue.new
            obj.blank?.must_equal true
          end
          
          it "should return false when given an Object whose :empty? method returns false" do 
            obj = EmptyFalse.new
            obj.blank?.must_equal false
          end
          
        end #/the :blank? method
        
        describe "#present?" do 
          
          NOT.each do |v|
            it "#present? should return true for '#{v.inspect}'" do
              v.present?.must_equal true
            end
          end
          
          BLANK.each do |v|
            it "should return false for '#{v.inspect}'" do
              v.present?.must_equal false
            end
          end
          
        end #/ #present?
        
        describe "#presence" do 
          
          NOT.each do |v|
            it "#presence should return the receiver for '#{v.inspect}'" do
              v.presence.must_equal v
            end
          end
          
          BLANK.each do |v|
            it "#presence should return nil for '#{v.inspect}'" do
              v.presence.must_be_nil
            end
          end
          
        end #/ #presence
        
      end #/ Object
      
      
      describe String do 
        
        it "should respond to :blank?" do 
          String.must_respond_to(:blank?)
        end
        
        it "should be blank if empty" do 
          ''.blank?.must_equal true
        end
        
        it 'should be blank if it only contains whitespace' do
          ' '.blank?.must_equal true
          " \r \n \t ".blank?.must_equal true
        end
        
        it 'should not be blank if it contains non-whitespace' do
          'not blank'.blank?.must_equal false
        end
        
      end #/ String
      
      describe NilClass do 
        
        it "should respond to :blank?" do 
          NilClass.must_respond_to(:blank?)
        end
        
        it "should always be blank" do 
          nil.blank?.must_equal true # nil should return true, not false
        end
        
      end #/ NilClass
      
      describe FalseClass do 
        
        it "should respond to :blank?" do 
          FalseClass.must_respond_to(:blank?)
        end
        
        it "should always be blank" do 
          false.blank?.must_equal true
        end
        
      end #/ FalseClass
      
      describe TrueClass do 
        
        it "should respond to :blank?" do 
          TrueClass.must_respond_to(:blank?)
        end
        
        it "should never be blank" do 
          true.blank?.must_equal false
        end
        
      end #/ TrueClass
      
      
      describe Array do 
        
        it "should respond to :blank?" do 
          Array.must_respond_to(:blank?)
          [].must_respond_to(:blank?)
        end
        
        it "should be blank when empty" do 
          [].blank?.must_equal true
        end
        
        it "should NOT be blank if not nil or empty" do 
          ['value'].blank?.must_equal false
        end
        
      end #/ Array
      
      describe Hash do 
        
        it "should respond to :blank?" do 
          Hash.must_respond_to(:blank?)
          {}.must_respond_to(:blank?)
        end
        
        it "should be blank when empty" do 
          {}.blank?.must_equal true
        end
        
        it "should NOT be blank if not nil or empty" do 
          {:a => :b}.blank?.must_equal false
        end
        
      end #/ Hash
      
      describe Numeric do 
        
        it "should respond to :blank?" do 
          Numeric.must_respond_to(:blank?)
          1.must_respond_to(:blank?)
        end
        
        it "should never be blank" do 
          1.blank?.must_equal false
          "100923".to_i.blank?.must_equal false
        end
        
      end #/ Numeric
      
      describe Time do 
        
        it "should respond to :blank?" do 
          Time.must_respond_to(:blank?)
          Time.now.must_respond_to(:blank?)
        end
        
        it "should never be blank" do 
          Time.now.blank?.must_equal false
        end
        
      end #/ Time
      
    end
    
  end
  
end
