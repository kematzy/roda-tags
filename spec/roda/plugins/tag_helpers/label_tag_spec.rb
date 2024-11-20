# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#label_tag' do
            describe 'basic rendering' do
              it 'renders basic label with default text' do
                html = tag_helpers_app('<%= label_tag(:username) %>')
                _(html).must_equal "<label for=\"username\">Username:</label>\n"
                _(html).must_have_tag('label[@for="username"]', 'Username:')
              end

              it 'handles symbols and strings equivalently' do
                html1 = tag_helpers_app('<%= label_tag(:user_name) %>')
                html2 = tag_helpers_app('<%= label_tag("user_name") %>')
                _(html1).must_equal html2
              end

              it 'handles empty or nil field names' do
                html = tag_helpers_app('<%= label_tag("") %>')
                _(html).must_have_tag('label[@for=""]')

                html = tag_helpers_app('<%= label_tag(nil) %>')
                _(html).must_have_tag('label[@for=""]')
              end
            end
            # /basic rendering

            describe 'label text customization' do
              it 'accepts custom label text' do
                html = tag_helpers_app('<%= label_tag(:username, label: "Enter Username") %>')
                _(html).must_have_tag('label', 'Enter Username:')
              end

              it 'handles nil label value by using titleized field name' do
                html = tag_helpers_app('<%= label_tag(:user_name, label: nil) %>')
                _(html).must_have_tag('label', 'User Name:')
              end

              it 'removes label text when label: false' do
                html = tag_helpers_app('<%= label_tag(:username, label: false) %>')
                _(html).must_have_tag('label[@for="username"]', '')
              end

              it 'handles empty string label' do
                html = tag_helpers_app('<%= label_tag(:username, label: "") %>')
                _(html).must_have_tag('label[@for="username"]', '')
              end
            end
            # /label text customization

            describe 'required field handling' do
              it 'adds required indicator when specified' do
                _(tag_helpers_app('<%= label_tag(:username, required: true) %>'))
                  .must_have_tag('label', 'Username: <span>*</span>')
              end

              it 'combines required indicator with custom label' do
                _(tag_helpers_app('<%= label_tag(:username, label: "Custom", required: true) %>'))
                  .must_have_tag('label', 'Custom: <span>*</span>')
              end

              it 'handles required with empty label' do
                _(tag_helpers_app('<%= label_tag(:username, label: "", required: true) %>'))
                  .must_have_tag('label', '')
              end
            end
            # /required field handling

            describe 'attribute handling' do
              it 'supports custom classes' do
                _(tag_helpers_app('<%= label_tag(:username, class: "required highlight") %>'))
                  .must_have_tag('label.required.highlight')
              end

              it 'supports data attributes' do
                _(tag_helpers_app('<%= label_tag(:username, data: { test: "value" }) %>'))
                  .must_have_tag('label[@data-test="value"]')
              end

              it 'supports custom for attribute' do
                _(tag_helpers_app('<%= label_tag(:username, for: "custom-id") %>'))
                  .must_have_tag('label[@for="custom-id"]')
              end

              it 'does not allow removing the for attribute' do
                _(tag_helpers_app('<%= label_tag(:username, for: false) %>'))
                  .must_have_tag('label[@for=username]')
              end
            end
            # /attribute handling

            describe 'block content' do
              it 'supports basic block content' do
                template = <<~ERB
                  <% label_tag(:username) do %>
                    <%= text_field_tag(:username) %>
                  <% end %>
                ERB

                html = tag_helpers_app(template)
                _(html).must_have_tag('label[@for="username"]')
                _(html).must_have_tag('label > input[@type="text"][@name="username"]')
              end

              it 'combines label text with block content' do
                template = <<~ERB
                  <% label_tag(:accept, label: "Terms") do %>
                    <%= check_box_tag(:accept) %>
                    Agree to terms
                  <% end %>
                ERB

                _(tag_helpers_app(template))
                  .must_match(/Terms:.*checkbox.*Agree to terms/m)
              end

              it 'handles required indicator in block content' do
                template = <<~ERB
                  <% label_tag(:username, required: true) do %>
                    <%= text_field_tag(:username) %>
                  <% end %>
                ERB

                _(tag_helpers_app(template))
                  .must_have_tag('label', %r{Username: <span>\*</span>.*<input}m)
              end
            end
            # /block content

            describe 'security concerns' do
              it 'escapes HTML in label text' do
                skip 'TODO: add suppport for value sanitation'
                # html = tag_helpers_app(
                #   '<%= label_tag(:username, label: "<script>alert(\'xss\')</script>") %>'
                #   )
                # _(html).must_include '&lt;script&gt;'
                # _(html).wont_include '<script>'
              end

              it 'escapes HTML in for attribute' do
                skip 'TODO: add suppport for value sanitation'
                # html = tag_helpers_app('<%= label_tag(:username, for: "<script>") %>')
                # _(html).wont_include '<script>'
              end
            end
            # /security concerns
          end
          # / #label_tag
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
