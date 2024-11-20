# frozen_string_literal: false

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe 'private' do
            describe '#html_safe_id' do
              it "returns a safe id from 'snippet_name'" do
                html = tag_helpers_app('<%= self.send(:html_safe_id, "snippet_name") %>')

                _(html).must_equal 'snippet_name'
              end

              it "returns a safe id from 'snippet name'" do
                html = tag_helpers_app('<%= self.send(:html_safe_id, "snippet name") %>')

                _(html).must_equal 'snippet-name'
              end

              it "returns a safe id from 'SnippetName'" do
                html = tag_helpers_app('<%= self.send(:html_safe_id, "SnippetName") %>')

                _(html).must_equal 'snippetname'
              end

              it "returns a safe id from 'Snippet::Category'" do
                html = tag_helpers_app('<%= self.send(:html_safe_id, "Snippet::Category") %>')

                _(html).must_equal 'snippet-category'
              end
            end

            describe '#add_css_class' do
              it 'returns the combined classes' do
                html = tag_helpers_app(
                  '<%= self.send(:add_css_class, { class: ["alert"]}, ["alert-info"]) %>'
                )

                _(html).must_equal '{:class=>"alert alert-info"}'
              end

              it 'handles no {:class} and nil values being passed in' do
                _(tag_helpers_app('<%= self.send(:add_css_class, {id: :idval}, nil) %>'))
                  .must_equal '{:id=>:idval, :class=>nil}'

                _(tag_helpers_app('<%= self.send(:add_css_class, {}, nil) %>'))
                  .must_equal '{:class=>nil}'

                _(tag_helpers_app('<%= self.send(:add_css_class, {}, "") %>'))
                  .must_equal '{:class=>nil}'
              end

              it 'handles no {:class} being passed in' do
                html = tag_helpers_app('<%= self.send(:add_css_class, {}, ["alert-info"]) %>')

                _(html).must_equal '{:class=>"alert-info"}'
              end

              it 'orders classes alphabetically' do
                html = tag_helpers_app(
                  '<%= self.send(:add_css_class, { class: "a c d"}, [:e, :b]) %>'
                )

                _(html).must_equal '{:class=>"a b c d e"}'
              end

              it 'handles duplicate class values' do
                html = tag_helpers_app(
                  '<%= self.send(:add_css_class, {class: "alert text"}, [:alert, "alert-info"]) %>'
                )

                _(html).must_equal '{:class=>"alert alert-info text"}'
              end

              it 'handles other attr values' do
                html = tag_helpers_app(
                  '<%= self.send(:add_css_class, {class: "text", id: :idval}, [:alert]) %>'
                )

                _(html).must_equal '{:class=>"alert text", :id=>:idval}'
              end

              it 'handles a mix of string, :symbol and array values being passed' do
                html = tag_helpers_app(
                  '<%= self.send(:add_css_class, {class: "alert text"}, [:alert, :info]) %>'
                )

                _(html).must_equal '{:class=>"alert info text"}'
              end

              it 'handles combining strings being passed' do
                html = tag_helpers_app(
                  '<%= self.send(:add_css_class, { class: "big" }, "text") %>'
                )

                _(html).must_equal '{:class=>"big text"}'
              end

              it 'handles combining symbols being passed' do
                html = tag_helpers_app(
                  '<%= self.send(:add_css_class, { class: :big}, :text) %>'
                )

                _(html).must_equal '{:class=>"big text"}'
              end

              it 'handles combining strings being passed' do
                code = '<% attrs = {id: :idval, class: :big} %>'
                code << '<% attrs = self.send(:add_css_class, attrs, :text) %><%= attrs %>'

                _(tag_helpers_app(code)).must_equal '{:id=>:idval, :class=>"big text"}'
              end
            end

            describe '#add_css_id' do
              it 'handles {} and nil values being passed in' do
                _(tag_helpers_app('<%= self.send(:add_css_id, nil, nil) %>'))
                  .must_equal '{:id=>nil}'

                _(tag_helpers_app('<%= self.send(:add_css_id, {}, nil) %>'))
                  .must_equal '{:id=>nil}'

                _(tag_helpers_app('<%= self.send(:add_css_id, nil, {}) %>'))
                  .must_equal '{:id=>nil}'

                _(tag_helpers_app('<%= self.send(:add_css_id, {}, "") %>'))
                  .must_equal '{:id=>nil}'
              end

              it 'handles {} and nil values being passed in with an id' do
                _(tag_helpers_app('<%= self.send(:add_css_id, nil, :idval) %>'))
                  .must_equal '{:id=>"idval"}'

                _(tag_helpers_app('<%= self.send(:add_css_id, nil, "idval") %>'))
                  .must_equal '{:id=>"idval"}'

                _(tag_helpers_app('<%= self.send(:add_css_id, {}, :idval) %>'))
                  .must_equal '{:id=>"idval"}'

                _(tag_helpers_app('<%= self.send(:add_css_id, {}, "idval") %>'))
                  .must_equal '{:id=>"idval"}'
              end

              it 'handles values being passed in correctly' do
                _(tag_helpers_app('<%= self.send(:add_css_id, {}, :name) %>'))
                  .must_equal '{:id=>"name"}'
              end

              it 'should retain and not overwrite the { :id } value passed in' do
                _(tag_helpers_app('<%= self.send(:add_css_id, {id: :snippet }, :name) %>'))
                  .must_equal '{:id=>"snippet"}'
              end
            end

            describe '#select_options' do
              it 'handles a nil values being passed' do
                _(tag_helpers_app('<%= self.send(:select_options, nil, nil) %>'))
                  .must_equal ''
              end

              it 'handles a flat Array [:a,:b,:c] being passed' do
                html = tag_helpers_app('<%= self.send(:select_options, [:a,:b], nil) %>')

                _(html).must_equal(
                  %(<option value="a">A</option>\n<option value="b">B</option>\n)
                )
                _(html).must_have_tag('option[@value=a]', 'A')
                _(html).must_have_tag('option[@value=b]', 'B')
              end

              it 'handles a flat Hash {a: :A,b: :B,c: :C} being passed' do
                html = tag_helpers_app('<%= self.send(:select_options, {a: :A, b: :B}, nil) %>')

                _(html).must_equal(
                  %(<option value="a">A</option>\n<option value="b">B</option>\n)
                )
                _(html).must_have_tag('option[@value=a]', 'A')
                _(html).must_have_tag('option[@value=b]', 'B')
              end

              it 'handles a Hash being passed' do
                html = tag_helpers_app('<%= self.send(:select_options, {a: "A", b: "B"}, nil) %>')

                _(html).must_equal(
                  %(<option value="a">A</option>\n<option value="b">B</option>\n)
                )
                _(html).must_have_tag('option[@value=a]', 'A')
                _(html).must_have_tag('option[@value=b]', 'B')
              end

              it 'handles a Hash within an Array being passed' do
                html = tag_helpers_app(
                  '<%= self.send(:select_options, [[:a,:A],{d: :D},[:c,:C]], nil) %>'
                )

                res = <<~HTML
                  <option value="a">A</option>
                  <optgroup label="">
                  <option value="d">D</option>
                  </optgroup>
                  <option value="c">C</option>
                HTML

                _(html).must_equal(res)
                _(html).must_have_tag('option[@value=a]', 'A')
                _(html).must_have_tag('optgroup > option[@value=d]', 'D')
                _(html).must_have_tag('option[@value=c]', 'C')
              end
            end
          end
          # /private
        end
        # /InstanceMethods
      end
      # /plugin :tag_helpers
    end
    # /RodaTagHelpers
  end
  # /RodaPlugins
end
# /Roda
# rubocop:enable Metrics/BlockLength
