# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#hidden_field_tag' do
            describe 'basic rendering' do
              it 'renders minimal field with name only' do
                html = tag_helpers_app('<%= hidden_field_tag(:token) %>')
                _(html).must_equal %(<input id="token" name="token" type="hidden" value="">\n)
              end

              it 'handles nil attributes gracefully' do
                html = tag_helpers_app('<%= hidden_field_tag(:token, nil) %>')
                _(html).must_equal %(<input id="token" name="token" type="hidden" value="">\n)
              end
            end
            # /basic rendering

            describe 'value handling' do
              it 'renders with explicit value' do
                html = tag_helpers_app('<%= hidden_field_tag(:token, value: "abc123") %>')
                _(html).must_have_tag('input[@value="abc123"]')
              end

              it 'handles empty value' do
                html = tag_helpers_app('<%= hidden_field_tag(:token, value: "") %>')
                _(html).must_have_tag('input[@value=""]')
              end

              it 'converts non-string values to strings' do
                html = tag_helpers_app('<%= hidden_field_tag(:count, value: 42) %>')
                _(html).must_have_tag('input[@value="42"]')
              end
            end
            # /value handling

            describe 'attribute handling' do
              it 'supports custom id' do
                html = tag_helpers_app('<%= hidden_field_tag(:token, id: "custom-id") %>')
                _(html).must_have_tag('input#custom-id')
                _(html).must_have_tag('input[@name="token"]')
              end

              it 'allows removing id attribute' do
                html = tag_helpers_app('<%= hidden_field_tag(:token, id: false) %>')
                _(html).wont_have_tag('input[@id]')
              end

              it 'supports custom name attribute' do
                html = tag_helpers_app('<%= hidden_field_tag(:token, name: "custom_name") %>')
                _(html).must_have_tag('input[@name="custom_name"]')
              end

              it 'supports data attributes' do
                html = tag_helpers_app('<%= hidden_field_tag(:token, data: { role: "auth", type: "token" }) %>')
                _(html).must_have_tag('input[@data-role="auth"][@data-type="token"]')
              end
            end
            # /attribute handling

            describe 'complex scenarios' do
              it 'combines multiple attributes correctly' do
                html = tag_helpers_app(<<-ERB)
                  <%= hidden_field_tag(:token,
                    value: 'abc123',
                    id: 'auth-token',
                    name: 'auth[token]',
                    data: { expires: '3600' }
                  ) %>
                ERB

                _(html).must_have_tag('input#auth-token')
                _(html).must_have_tag('input[@name="auth[token]"]')
                _(html).must_have_tag('input[@value="abc123"]')
                _(html).must_have_tag('input[@data-expires="3600"]')
              end

              it 'handles array-style names' do
                html = tag_helpers_app('<%= hidden_field_tag("items[]", value: "1") %>')
                _(html).must_have_tag('input[@name="items[]"][@value="1"]')
              end
            end
            # /complex scenarios

            describe 'edge cases' do
              it 'handles non-string field names safely' do
                html = tag_helpers_app('<%= hidden_field_tag(123) %>')
                _(html).must_have_tag('input[@name="123"]')
              end

              it 'handles symbol values' do
                html = tag_helpers_app('<%= hidden_field_tag(:token, value: :active) %>')
                _(html).must_have_tag('input[@value="active"]')
              end

              it 'handles boolean values' do
                html = tag_helpers_app('<%= hidden_field_tag(:active, value: true) %>')
                _(html).must_have_tag('input[@value="true"]')
              end

              it 'handles nil field name' do
                html = tag_helpers_app('<%= hidden_field_tag(nil) %>')
                _(html).must_have_tag('input[@name=""]')
              end

              it 'handles empty string field name' do
                html = tag_helpers_app('<%= hidden_field_tag("") %>')
                _(html).must_have_tag('input[@name=""]')
              end
            end
            # /edge cases

            describe 'form integration' do
              it 'works within form_tag' do
                template = <<~ERB
                  <% form_tag('/submit') do %>
                    <%= hidden_field_tag(:token, value: 'abc123') %>
                  <% end %>
                ERB

                html = tag_helpers_app(template)
                _(html).must_have_tag('form > input[@type="hidden"][@name="token"]')
                _(html).must_have_tag('form > input[@type="hidden"][@value="abc123"]')
              end

              it 'supports multiple hidden fields' do
                template = <<~ERB
                  <% form_tag('/submit') do %>
                    <%= hidden_field_tag(:token, value: 'abc') %>
                    <%= hidden_field_tag(:timestamp, value: '123') %>
                  <% end %>
                ERB

                html = tag_helpers_app(template)
                _(html).must_have_tag('form > input[@name="token"][@value="abc"]')
                _(html).must_have_tag('form > input[@name="timestamp"][@value="123"]')
              end
            end
            # /form integration
          end
          # / #hidden_field_tag
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
