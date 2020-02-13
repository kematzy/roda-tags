require_relative '../spec_helper'

describe Roda do

  describe 'RodaPlugins' do

    describe 'RodaTags => :tags' do

      describe ':tags opts' do

        describe 'defaults' do
          before do
            @a = Class.new(Roda)
            @a.plugin(:tags)
          end

          it 'should have the default settings' do
            expected = {
              tag_output_format_is_xhtml:  false,
              tag_add_newlines_after_tags: true,
              # tags_label_required_str:     "<span>*</span>",
              # tags_label_append:            ":",
              orig_opts: {
                tag_output_format_is_xhtml:   false,
                tag_add_newlines_after_tags:  true,
                # tags_label_required_str:      "<span>*</span>",
                # tags_label_append:            ":"
              }
            }
            _(@a.tags_opts).must_equal(expected)
          end

          describe '#:tag_output_format_is_xhtml' do

            it 'should return false' do
              _(tag_app('<%= output_is_xhtml?.inspect %>')).must_equal "false"
              _(tag_app('<%= output_is_xhtml?.inspect %>', {}, { tag_output_format_is_xhtml: false })).must_equal "false"
            end

          end

        end

        describe 'custom settings' do
          before do
            @b = Class.new(Roda)
            @b.plugin(:tags, tag_output_format_is_xhtml: true, tag_add_newlines_after_tags: false)
          end

          it 'should have the custom settings' do
            expected = {
              tag_output_format_is_xhtml:  true,
              tag_add_newlines_after_tags: false,
              orig_opts: {
                tag_output_format_is_xhtml:   true,
                tag_add_newlines_after_tags:  false,
              }
            }
            _(@b.tags_opts).must_equal(expected)
          end


          it 'should set :tag_output_format_is_xhtml: to true' do
            _(@b.tags_opts[:tag_output_format_is_xhtml]).must_equal true
          end

          describe '#:tag_output_format_is_xhtml' do

            it 'should return true' do
              _(tag_app('<%= output_is_xhtml?.inspect %>', {}, { tag_output_format_is_xhtml: true })).must_equal "true"
            end

          end

        end

        describe 'double loading of plugin' do
          before do
            @c = Class.new(Roda)
            @c.plugin(:tags, tag_output_format_is_xhtml: true, tag_add_newlines_after_tags: false)
            @d = Class.new(@c)
            @d.plugin(:tags, tag_output_format_is_xhtml: false)
          end

          it 'should have the custom settings' do
            expected = {
              tag_output_format_is_xhtml:  false,
              tag_add_newlines_after_tags: false,
              orig_opts: {
                tag_output_format_is_xhtml:   false,
                tag_add_newlines_after_tags:  false,
              }
            }
            _(@d.tags_opts).must_equal(expected)
          end

        end

      end

      describe 'Instance Methods' do

        describe '#tag' do

          describe "multi line tags " do

            Roda::RodaPlugins::RodaTags::MULTI_LINE_TAGS.each do |t|

              describe "like <#{t}>" do

                it "should have a '\\n' after the opening tag and before the closing tag" do
                  _(tag_app("<%= tag(:#{t},'contents') %>")).must_equal "<#{t}>\ncontents\n</#{t}>\n"
                end

                it "should work without contents passed in" do
                  _(tag_app("<%= tag(:#{t},nil) %>")).must_equal "<#{t}>\n</#{t}>\n"
                end

                it "should allow a hash of attributes to be passed" do
                  _(tag_app("<%= tag(:#{t},'contents', id: 'tid', class: 'klass') %>"))
                  .must_match(/class="klass" id="tid"/)
                  # body.should have_tag("#{t}#tag-id.tag-class","\ncontents\n")
                end

                it "with ':newline => false' should NOT add '\\n' around the contents" do
                  _(tag_app("<%= tag(:#{t},'content', :id => 'tag-id', :newline => false) %>"))
                    .must_equal "<#{t} id=\"tag-id\">content</#{t}>\n"
                end

              end #/ like ##{t}

            end #/ loop

            describe "like <textarea>" do

              it "should NOT have a '\\n' after the opening tag and before the closing tag" do
                _(tag_app("<%= tag(:textarea,'contents') %>")).must_equal "<textarea>contents</textarea>\n"
              end

              it "should work without contents passed in" do
                _(tag_app("<%= tag(:textarea,nil) %>")).must_equal "<textarea></textarea>\n"
              end

              it "should allow a hash of attributes to be passed" do

                assert_have_tag(
                  tag_app("<%= tag(:textarea,'contents', :id => 'tag-id', :class => 'tag-class') %>"),
                  "textarea#tag-id.tag-class"
                )
              end

              it "with ':newline => false' should NOT add '\\n' around the contents" do
                _(tag_app("<%= tag(:textarea,'content', id: 'tag-id', newline: false) %>"))
                  .must_equal %Q{<textarea id=\"tag-id\">content</textarea>\n}
              end

            end #/ like #textarea

          end #/ multi line tags

          describe "self closing tags " do

            Roda::RodaPlugins::RodaTags::SELF_CLOSING_TAGS.each do |t|

              describe "like <#{t}>" do

                it "should have a '\\n' after the opening tag and before the closing tag" do
                  _(tag_app("<%= tag(:#{t},'contents') %>")).must_equal "<#{t}>\n"
                end

                it "should add a '/' to close the tag if format is XHTML" do
                  _(tag_app("<%= tag(:#{t}) %>", {}, { tag_output_format_is_xhtml: true } )).must_equal "<#{t} />\n"
                end

                it "should work without contents passed in" do
                  _(tag_app("<%= tag(:#{t},nil) %>")).must_equal "<#{t}>\n"
                end

                it "should ignore the contents passed in" do
                  _(tag_app("<%= tag(:#{t},'contents') %>")).must_equal "<#{t}>\n"
                end

                it "should allow a hash of attributes to be passed" do
                  _(tag_app("<%= tag(:#{t},'contents', id: 'tid', class: 'klass') %>"))
                    .must_match(/class="klass" id="tid"/)
                end

                it "with ':newline => false' should NOT add '\\n' around the contents" do
                  _(tag_app("<%= tag(:#{t},'content', :id => 'tag-id', :newline => false) %>"))
                    .must_equal "<#{t} id=\"tag-id\">"
                end

              end #/ like ##{t}

            end #/ loop

            describe "like <textarea>" do

              it "should NOT have a '\\n' after the opening tag and before the closing tag" do
                _(tag_app("<%= tag(:textarea,'contents') %>")).must_equal "<textarea>contents</textarea>\n"
              end

              it "should work without contents passed in" do
                _(tag_app("<%= tag(:textarea,nil) %>")).must_equal "<textarea></textarea>\n"
              end

              it "should allow a hash of attributes to be passed" do

                assert_have_tag(
                  tag_app("<%= tag(:textarea,'contents', id: 'tag-id', class: 'tag-class') %>"),
                  "textarea#tag-id.tag-class"
                )
              end

              it "with ':newline => false' should NOT add '\\n' around the contents" do
                _(tag_app("<%= tag(:textarea,'content', id: 'tag-id', newline: false) %>"))
                  .must_equal %Q{<textarea id=\"tag-id\">content</textarea>\n}
              end

            end #/ like #textarea

          end #/ multi line tags

          it 'should return the correct <br> tag' do
            _(tag_app('<%= tag(:br) %>')).must_equal "<br>\n"
            _(tag_app('<%= tag(:br) %>', {}, { tag_output_format_is_xhtml: true } ).strip).must_equal "<br />"
          end

          it 'should return the correct <div> tag' do
            _(tag_app("<%= tag(:div) %>")).must_equal "<div>\n</div>\n"
          end

          it 'should return the correct <section> tag' do
            _(tag_app("<%= tag(:section) %>")).must_equal "<section>\n</section>\n"
          end

          it 'should return the correct <input> tag' do
            _(tag_app("<%= tag(:input, type: :text, id: :idval, class: :klass) %>")).must_equal %Q{<input class=\"klass\" id=\"idval\" type=\"text\">\n}
          end

          it 'should handle data hashes correctly' do
            _(tag_app("<%= tag(:div, id: 'ID', class: 'klass', data: { c: 'C', b: 'B', a: 'A' }) %>"))
              .must_equal %Q{<div class="klass" data-a="A" data-b="B" data-c="C" id="ID">\n</div>\n}
          end

          it 'should handle block output correctly' do
            str = <<-ERB
<% tag(:section, id: :intro, class: :row) do %>
  <% tag(:div, class: 'col-md-12') do %>
    <h1>Blocks Works too</h1>
  <% end %>
<% end %>
ERB
            _(tag_app(str))
              .must_equal %Q{<section class="row" id="intro">\n<div class="col-md-12">\n    <h1>Blocks Works too</h1>\n</div>\n</section>\n}

          end

        end

        describe '#merge_attr_classes' do

          it 'should merge the given classes' do
            _(tag_app('<%= merge_attr_classes({ class: "a b d" }, "c") %>')).must_equal '{:class=>"a b c d"}' #"a b c d"
          end

          it 'should merge the given classes and return only uniq classes' do
            _(tag_app('<%= merge_attr_classes({ class: "a b d" }, "a b") %>')).must_equal '{:class=>"a b d"}' #"a b d"
          end

        end

        describe '#merge_classes' do

          #   attr = { class: 'alert', id: :idval }
          #
          #   merge_classes(attr[:class], ['alert', 'alert-info'])  #=> 'alert alert-info'
          #
          #   merge_classes(attr[:class], :text)  #=> 'alert text'
          #
          #   merge_classes(attr[:class], [:text, :'alert-info'])  #=> 'alert alert-info text'


          it 'should correctly handle being passed empty arrays' do
            _(tag_app('<% @a={ class: [] } %><%= merge_classes(@a[:class], []) %>')).must_equal ""
          end

          it 'should correctly handle being passed nil attrs and an empty array' do
            _(tag_app('<%= merge_classes(nil, []) %>')).must_equal ""
          end

          it 'should correctly handle being passed nil values only' do
            _(tag_app('<%= merge_classes(nil, nil) %>')).must_equal ""
          end

          it 'should correctly handle being passed empty hash values only' do
            _(tag_app('<%= merge_classes({}, {}) %>')).must_equal ""
          end

          it 'should correctly handle being passed nil & empty array' do
            _(tag_app('<% @a={ class: nil   } %><%= merge_classes(@a[:class], []) %>')).must_equal ""
            _(tag_app('<% @a={ class: nil   } %><%= merge_classes(@a[:class], nil) %>')).must_equal ""
            _(tag_app('<% @a={ class: nil   } %><%= merge_classes(@a[:class], [nil]) %>')).must_equal ""
            _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], nil) %>')).must_equal ""
            _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], [nil]) %>')).must_equal ""
            _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], [:alert]) %>')).must_equal "alert"
            _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], [:alert, nil]) %>')).must_equal "alert"
          end

          it 'should correctly handle removing duplicate values' do
            _(tag_app('<%= merge_classes({class: :alert }, :alert) %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: :alert }, [:alert]) %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: [:alert] }, :alert) %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: [:alert] }, [:alert]) %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: "alert" }, :alert) %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: "alert" }, [:alert]) %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: ["alert"] }, [:alert]) %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: "alert" }, "alert") %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: "alert" }, ["alert"]) %>')).must_equal "alert"
            _(tag_app('<%= merge_classes({class: ["alert"] }, ["alert"]) %>')).must_equal "alert"
          end

          it 'should correctly merge the given classes when passed an empty array & array[strings]' do
            _(tag_app('<% @a={ class: [] } %><%= merge_classes(@a[:class], ["alert", "alert-info"]) %>')).must_equal "alert alert-info"
          end

          it 'should correctly merge the given classes when passed nil & one with array[strings]' do
            _(tag_app('<% @a={ class: nil   } %><%= merge_classes(@a[:class], ["alert", "alert-info"]) %>')).must_equal "alert alert-info"
            _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], ["alert", "alert-info"]) %>')).must_equal "alert alert-info"
          end

          it 'should correctly merge the given classes when passed arrays with strings' do
            _(tag_app('<% @a={ class: ["alert"] } %><%= merge_classes(@a[:class], ["alert", "alert-info"]) %>')).must_equal "alert alert-info"
          end

          it 'should correctly merge the given classes when passed string & array' do
            _(tag_app('<% @a={ class: "alert" } %><%= merge_classes(@a[:class], ["alert", "alert-danger"]) %>')).must_equal "alert alert-danger"
          end

          it 'should correctly merge the given classes when passed symbol & array' do
            _(tag_app('<% @a={ class: :alert } %><%= merge_classes(@a[:class], ["alert", "alert-danger"]) %>')).must_equal "alert alert-danger"
          end

          it 'should correctly merge the given classes when passed array[symbol] & array' do
            _(tag_app('<% @a={ class: [:alert, "error"] } %><%= merge_classes(@a[:class], ["alert", "alert-danger"]) %>')).must_equal "alert alert-danger error"
          end

          it 'should correctly merge the given classes when passed array[symbol] & :symbol' do
            _(tag_app('<% @a={ class: [:alert] } %><%= merge_classes(@a[:class], :text) %>')).must_equal "alert text"
          end

          it 'should correctly merge the given classes when passed string & :symbol' do
            _(tag_app('<% @a={ class: "alert" } %><%= merge_classes(@a[:class], :text) %>')).must_equal "alert text"
          end
          it 'should correctly merge the given classes when passed :symbol & :symbol' do
            _(tag_app('<% @a={ class: :alert } %><%= merge_classes(@a[:class], :text) %>')).must_equal "alert text"
            _(tag_app('<% @a={ class: :"alert-info" } %><%= merge_classes(@a[:class], :text) %>')).must_equal "alert-info text"
          end

        end

        describe '#capture' do

          it "should capture the whitespace of the block but not the silent '<% tag(:br) %>' tag output" do
            _(tag_app(%Q{<% capture() do %> <% tag(:br) %> <% end %>})).must_equal '  '
          end

          it "should capture the whitespace of the block including the '<%= tag(:br) %>' output" do
            _(tag_app(%Q{<% capture() do %>|<%= tag(:br) %>|<% end %>})).must_equal %Q{|<br>\n|}
          end

          it 'should capture the contents of a mixed block' do
            str = <<-ERB
<% capture() do %>
  <% tag(:div, class: 'row') do %>
    <% tag(:div, class: 'col-md-12') do %>
      <%= tag(:h1, 'Capture Works too') %>
      <%- tag(:h2) do %>
        Nested capture works too
      <%- end %>
    <% end %>
  <% end %>
<% end %>
ERB
            html = tag_app(str)
            _(html).must_have_tag('div.row > div[@class="col-md-12"] > h1', 'Capture Works too')
            _(html.strip).must_have_tag('div.row > div[@class="col-md-12"] > h2', %Q{        Nested capture works too
})
          end

        end

        describe '#tag_contents_for' do

          it 'should handle a single line tag with new lines true' do
            html = tag_app(%Q{<%= tag_contents_for(:option, 'content', true) %>})
            _(html).must_equal "\ncontent\n"
          end

          it 'should handle a single line tag with new lines false' do
            html = tag_app(%Q{<%= tag_contents_for(:option, 'content', false) %>})
            _(html).must_equal "content"
          end

        end

        describe '#normalize_html_attributes' do

          it 'should handle empty attrs' do
            _(tag_app('<%= normalize_html_attributes({}) %>')).must_equal ""
          end

          it 'should handle basic attrs' do
            _(tag_app('<%= normalize_html_attributes({class: "alert"}) %>')).must_equal ' class="alert"'
          end

          it 'should handle data attrs' do
            _(tag_app('<%= normalize_html_attributes({data: { b: :B, a: :A }, class: "alert"}) %>'))
              .must_equal ' class="alert" data-a="A" data-b="B"'
          end

          it 'should handle boolean attrs' do
            _(tag_app('<%= normalize_html_attributes({data: { b: :B, a: :A }, class: "alert", selected: true}) %>'))
              .must_equal ' class="alert" data-a="A" data-b="B" selected="selected"'
            _(tag_app('<%= normalize_html_attributes({data: { b: :B, a: :A }, class: "alert", selected: false}) %>'))
              .must_equal ' class="alert" data-a="A" data-b="B"'
          end

        end

        describe '#concat_content' do

          it 'should handle within a block' do
            # html = tag_app(%Q{<%= capture() do %><% @r = concat_content('test') %><% end %>})
            # html = tag_app(%Q{<% @r = concat_content('test') %><%= @r.inspect %>})
            # html = tag_app(%Q{<% self.send(:concat_content,'test') %>})
            # html = tag_app(%Q{<%= 'A' %> <% concat_content('test') %>})
            # html = tag_app(%Q{<% capture() do %><%= 'A' %><% end %>})
            # _(html).must_equal 'test'
            # @r = _app do
            #   plugin :tags
            # end


            # @r = CC.app


            # @r = Class.new(Roda)
            # @r.plugin(:tags)

            # _(@r.concat_content('text')).must_equal ''
            # _(@r.app).must_be_kind_of(Roda)
            # _(@b.new.concat_content("text")).must_equal ''

            # app(:bare) do
            #   plugin(:tags)
            #   route do |r|
            #     r.root do
            #       view(:inline=>view, :layout=>{:inline=>'<%= yield %>'}.merge(opts))
            #     end
            #   end
            # end

            # html = tag_app(%Q{<%= concat_content('text') %>})
            # _(html).must_equal ''
          end

        end

      end

    end

  end

end
