require_relative '../spec_helper'


class CoreExtHashSpec < Minitest::Spec

  describe 'CoreExt' do

    describe '"core_ext/hash"' do
      require_relative '../../lib/core_ext/hash'


      describe Hash do

        let(:h) { { a: 'Hash'} }

        describe "should respond to" do

          it "#:to_html_attributes" do
            _(Hash).wont_respond_to(:to_html_attributes)
            _(Hash.new).must_respond_to(:to_html_attributes)
          end

          it "#:reverse_merge" do
            _(Hash).wont_respond_to(:reverse_merge)
            _(Hash.new).must_respond_to(:reverse_merge)
          end

          it "#:reverse_merge" do
            _(Hash).wont_respond_to(:reverse_merge!)
            _(Hash.new).must_respond_to(:reverse_merge!)
          end

          it "#:reverse_update" do
            _(Hash).wont_respond_to(:reverse_update)
            _(Hash.new).must_respond_to(:reverse_update)
          end

        end

        describe "#to_html_attributes" do

          before(:each) do
            @h = {:id => "home", :class => "index" }
          end

          it "should output all items in the hash" do
            _(@h.to_html_attributes).must_equal 'class="index" id="home"'
          end

          it "should handle empty values in the Hash" do
            @h[:empty] = ''
            _(@h.to_html_attributes).must_match(/empty=""/)
            _(@h.to_html_attributes).must_match(/class="index"/)
            _(@h.to_html_attributes).must_match(/id="home"/)
            # _(@h.to_html_attributes).must_equal 'class="index" empty="" id="home"'
          end

          it "should handle nil values in the Hash" do
            @h[:empty] = nil
            _(@h.to_html_attributes).must_match(/empty=""/)
            _(@h.to_html_attributes).must_match(/class="index"/)
            _(@h.to_html_attributes).must_match(/id="home"/)
            # _(@h.to_html_attributes).must_equal 'class="index" empty="" id="home"'
          end

          it "should handle Array values in the Hash" do
            @h[:array] = [:user, :name]
            _(@h.to_html_attributes).must_match(/array="user_name"/)
            _(@h.to_html_attributes).must_match(/class="index"/)
            _(@h.to_html_attributes).must_match(/id="home"/)
          end

          it "should remove empty attributes when passed :ignore_empty without modifying the original Hash" do
            @h[:empty] = nil
            @h[:empty_string] = ''
            @h.to_html_attributes(:ignore_empty) == 'class="index" id="home"'

            _(@h.to_html_attributes(:ignore_empty)).wont_match(/empty_string=""/)
            _(@h.to_html_attributes(:ignore_empty)).wont_match(/empty=""/)

            _(@h.to_html_attributes).must_match(/empty_string=""/)
            _(@h.to_html_attributes).must_match(/empty=""/)
            # _(@h.to_html_attributes).must_equal 'class="index" empty="" empty_string="" id="home"'
          end

        end #/ #to_html_attributes

        describe "reverse_merge*" do

          before(:each) do
            @defaults = { :a => "x", :b => "y", :c => 10 }.freeze
            @options  = { :a => 1, :b => 2 }
            @expected = { :a => 1, :b => 2, :c => 10 }
          end

          describe "#reverse_merge" do

            it "should merge defaults into options, creating a new hash" do
              _(@options.reverse_merge(@defaults)).must_equal @expected
              _(@expected).wont_equal @options
            end

          end #/ #reverse_merge

          describe "#reverse_merge!" do

            it "should merge! defaults into options, replacing options" do
              merged = @options.dup
              _(merged.reverse_merge!(@defaults)).must_equal @expected
              _(merged).must_equal @expected
            end

          end #/ #reverse_merge!

          describe "#reverse_update" do

            it "should be an alias for reverse_merge!" do
              merged = @options.dup
              _(merged.reverse_update(@defaults)).must_equal @expected
              _(merged).must_equal @expected
            end

          end #/ #reverse_update

        end #/ reverse_merge*

      end

    end

  end

end
