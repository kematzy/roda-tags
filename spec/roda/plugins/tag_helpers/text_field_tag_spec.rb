# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#text_field_tag' do
            describe 'basic rendering' do
              it 'renders minimal field with name only' do
                _(tag_helpers_app('<%= text_field_tag(:username) %>'))
                  .must_equal %(<input class="text" id="username" name="username" type="text">\n)
              end

              it 'handles nil attributes gracefully' do
                _(tag_helpers_app('<%= text_field_tag(:username, nil) %>'))
                  .must_equal %(<input class="text" id="username" name="username" type="text">\n)
              end
            end
            # /basic rendering

            describe 'value handling' do
              it 'renders with explicit value' do
                _(tag_helpers_app('<%= text_field_tag(:username, value: "john") %>'))
                  .must_have_tag('input[@value="john"]')
              end

              it 'handles empty value' do
                _(tag_helpers_app('<%= text_field_tag(:username, value: "") %>'))
                  .must_have_tag('input[@value=""]')
              end

              # it 'escapes HTML in values' do
              #   html = tag_helpers_app('<%= text_field_tag(:username, value: "<script>alert(\'xss\')</script>") %>')
              #   _(html).must_include('&lt;script&gt;')
              #   _(html).wont_include('<script>')
              # end
            end
            # /value handling

            describe 'attribute handling' do
              it 'supports custom id' do
                html = tag_helpers_app('<%= text_field_tag(:username, id: "custom-id") %>')
                _(html).must_have_tag('input#custom-id')
                _(html).must_have_tag('input[@name="username"]')
              end

              it 'allows removing id attribute' do
                _(tag_helpers_app('<%= text_field_tag(:username, id: false) %>'))
                  .wont_have_tag('input[@id]')
              end

              it 'merges CSS classes' do
                _(tag_helpers_app('<%= text_field_tag(:username, class: "large primary") %>'))
                  .must_have_tag('input.text.large.primary')
              end

              it 'preserves default text class when adding custom classes' do
                _(tag_helpers_app('<%= text_field_tag(:username, class: "custom") %>'))
                  .must_have_tag('input.text.custom')
              end
            end
            # /attribute handling

            describe 'UI hints' do
              it 'adds title from ui_hint' do
                _(tag_helpers_app('<%= text_field_tag(:username, ui_hint: "Enter username") %>'))
                  .must_have_tag('input[@title="Enter username"]')
              end

              it 'supports direct title attribute' do
                _(tag_helpers_app('<%= text_field_tag(:username, title: "Username field") %>'))
                  .must_have_tag('input[@title="Username field"]')
              end
            end
            # /UI hints

            describe 'size attributes' do
              it 'supports maxlength attribute' do
                _(tag_helpers_app('<%= text_field_tag(:username, maxlength: 50) %>'))
                  .must_have_tag('input[@maxlength="50"]')
              end

              it 'supports size attribute' do
                _(tag_helpers_app('<%= text_field_tag(:username, size: 30) %>'))
                  .must_have_tag('input[@size="30"]')
              end

              it 'handles both size and maxlength' do
                _(tag_helpers_app('<%= text_field_tag(:username, size: 30, maxlength: 50) %>'))
                  .must_have_tag('input[@size="30"][@maxlength="50"]')
              end
            end
            # /size attributes

            describe 'state attributes' do
              it 'supports disabled state' do
                _(tag_helpers_app('<%= text_field_tag(:username, disabled: true) %>'))
                  .must_have_tag('input[@disabled="disabled"]')
              end

              it 'supports readonly state' do
                _(tag_helpers_app('<%= text_field_tag(:username, readonly: true) %>'))
                  .must_have_tag('input[@readonly="readonly"]')
              end

              it 'handles false state attributes' do
                html = tag_helpers_app(
                  '<%= text_field_tag(:username, disabled: false, readonly: false) %>'
                )
                _(html).wont_have_tag('input[@disabled]')
                _(html).wont_have_tag('input[@readonly]')
              end
            end
            # /state attributes

            describe 'HTML5 attributes' do
              it 'supports placeholder attribute' do
                html = tag_helpers_app(
                  '<%= text_field_tag(:username, placeholder: "Enter username") %>'
                )
                _(html).must_have_tag('input[@placeholder="Enter username"]')
              end

              it 'supports pattern attribute' do
                _(tag_helpers_app('<%= text_field_tag(:username, pattern: "[A-Za-z]+") %>'))
                  .must_have_tag('input[@pattern="[A-Za-z]+"]')
              end

              it 'supports required attribute' do
                _(tag_helpers_app('<%= text_field_tag(:username, required: true) %>'))
                  .must_have_tag('input[@required="required"]')
              end
            end
            # /HTML5 attributes

            describe 'data attributes' do
              it 'supports single data attribute' do
                _(tag_helpers_app('<%= text_field_tag(:username, data: { value: "test" }) %>'))
                  .must_have_tag('input[@data-value="test"]')
              end

              it 'supports multiple data attributes' do
                _(tag_helpers_app(
                  '<%= text_field_tag(:username, data: { value: "test", type: "user" }) %>'
                ))
                  .must_have_tag('input[@data-value="test"][@data-type="user"]')
              end
            end
            # /data attributes

            describe 'complex scenarios' do
              it 'combines multiple attributes correctly' do
                html = tag_helpers_app(<<~ERB)
                  <%= text_field_tag(:username,
                    value: 'john',
                    class: 'large',
                    disabled: true,
                    maxlength: 50,
                    placeholder: 'Username',
                    data: { test: 'value' },
                    ui_hint: 'Enter username'
                  ) %>
                ERB

                _(html).must_have_tag('input#username.text.large')
                _(html).must_have_tag('input[@value="john"]')
                _(html).must_have_tag('input[@disabled="disabled"]')
                _(html).must_have_tag('input[@maxlength="50"]')
                _(html).must_have_tag('input[@placeholder="Username"]')
                _(html).must_have_tag('input[@data-test="value"]')
                _(html).must_have_tag('input[@title="Enter username"]')
              end
            end
            # /complex scenarios
          end
          # / #text_field_tag
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
