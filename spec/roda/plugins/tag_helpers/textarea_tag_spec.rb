# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#textarea_tag' do
            describe 'basic rendering' do
              it 'renders minimal textarea with name only' do
                html = tag_helpers_app('<%= textarea_tag(:post) %>')
                _(html).must_equal %(<textarea id="post" name="post"></textarea>\n)
              end

              it 'handles nil attributes gracefully' do
                html = tag_helpers_app('<%= textarea_tag(:post, nil) %>')
                _(html).must_equal %(<textarea id="post" name="post"></textarea>\n)
              end
            end
            # /basic rendering

            describe 'content handling' do
              it 'renders with explicit value' do
                html = tag_helpers_app("<%= textarea_tag(:post, value: 'some-value') %>")
                _(html).must_equal %(<textarea id="post" name="post">some-value</textarea>\n)
              end

              it 'handles empty value' do
                html = tag_helpers_app("<%= textarea_tag(:post, value: '') %>")
                _(html).must_equal %(<textarea id="post" name="post"></textarea>\n)
              end

              it 'handles special characters in content' do
                skip 'TODO: add suppport for value sanitation'
                # html = tag_helpers_app(
                #   '<%= textarea_tag(:post, value: "<script>alert(\'xss\')</script>") %>'
                # )
                # _(html).must_include '&lt;script&gt;'
                # _(html).wont_include '<script>'
              end
            end
            # /content handling

            describe 'attributes handling' do
              it 'supports custom id' do
                html = tag_helpers_app("<%= textarea_tag(:post, id: 'custom-id') %>")
                _(html).must_equal %(<textarea id="custom-id" name="post"></textarea>\n)
              end

              it 'supports removing id attribute' do
                html = tag_helpers_app("<%= textarea_tag(:post, id: false) %>")
                _(html).must_equal %(<textarea name="post"></textarea>\n)
              end

              it 'applies CSS classes' do
                html = tag_helpers_app('<%= textarea_tag(:post, class: "big bold") %>')
                _(html).must_equal %(<textarea class="big bold" id="post" name="post"></textarea>\n)
              end

              it 'adds title from ui_hint' do
                html = tag_helpers_app('<%= textarea_tag(:post, ui_hint: "Enter text here") %>')
                _(html).must_equal %(<textarea id="post" name="post" title="Enter text here"></textarea>\n)
              end
            end
            # /attributes handling

            describe 'dimension attributes' do
              it 'supports explicit rows and cols' do
                _(tag_helpers_app('<%= textarea_tag(:post, rows: 10, cols: 25) %>'))
                  .must_equal %(<textarea cols="25" id="post" name="post" rows="10"></textarea>\n)
              end

              it 'handles size shorthand' do
                _(tag_helpers_app('<%= textarea_tag(:post, size: "25x10") %>'))
                  .must_equal %(<textarea cols="25" id="post" name="post" rows="10"></textarea>\n)
              end

              it 'ignores invalid size format' do
                _(tag_helpers_app('<%= textarea_tag(:post, size: "invalid") %>'))
                  .must_equal %(<textarea id="post" name="post"></textarea>\n)
              end
            end
            # /dimension attributes

            describe 'state attributes' do
              it 'supports disabled state' do
                _(tag_helpers_app('<%= textarea_tag(:post, disabled: true) %>'))
                  .must_equal %(<textarea disabled="disabled" id="post" name="post"></textarea>\n)
              end

              it 'supports readonly state' do
                _(tag_helpers_app('<%= textarea_tag(:post, readonly: true) %>'))
                  .must_equal %(<textarea id="post" name="post" readonly="readonly"></textarea>\n)
              end

              it 'handles false state attributes' do
                _(tag_helpers_app('<%= textarea_tag(:post, disabled: false, readonly: false) %>'))
                  .must_equal %(<textarea id="post" name="post"></textarea>\n)
              end
            end
            # /state attributes

            describe 'complex scenarios' do
              it 'combines multiple attributes and content' do
                html = tag_helpers_app(<<-ERB)
                  <%= textarea_tag(:post,
                    value: 'Content',
                    class: 'big',
                    rows: 5,
                    cols: 20,
                    disabled: true,
                    ui_hint: 'Help text'
                  ) %>
                ERB

                _(html).must_have_tag('textarea#post.big')
                _(html).must_have_tag('textarea[@disabled=disabled]')
                _(html).must_have_tag('textarea[@rows="5"][@cols="20"]')
                _(html).must_have_tag('textarea[@title="Help text"]')
                _(html).must_include('Content')
              end

              # it 'handles nested content with HTML' do
              # TODO: figure out why this test fails with the following return:
              #   +"<textarea id=\"post\" name=\"post\">'.freeze;
              #       @_out_buf << '&lt;p&gt;Paragraph 1&lt;/p&gt;
              #   +&lt;p&gt;Paragraph 2&lt;/p&gt;
              #   +</textarea>
              #   +
              #   +"
              #
              #   html = tag_helpers_app(<<~ERB)
              #     <%= textarea_tag(:post, value: <<-CONTENT) %>
              #     &lt;p&gt;Paragraph 1&lt;/p&gt;
              #     &lt;p&gt;Paragraph 2&lt;/p&gt;
              #     CONTENT
              #   ERB

              #   _(html).must_equal('debug')

              #   _(html).must_include('Paragraph 1')
              #   _(html).must_include('Paragraph 2')
              #   _(html).wont_include('<p>')  # Should be escaped
              # end
            end
            # /complex scenarios
          end
          # / #textarea_tag
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
