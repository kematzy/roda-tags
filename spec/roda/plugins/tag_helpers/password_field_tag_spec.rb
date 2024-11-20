# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#password_field_tag' do
            describe 'renders a basic password field tag' do
              it 'when only the :name attribute is passed' do
                html = tag_helpers_app('<%= password_field_tag(:snippet_name) %>')

                _(html).must_equal(
                  %(<input class="text" id="snippet_name" name="snippet_name" type="password">\n)
                )
                _(html).must_have_tag('input[@type=password]')
                _(html).must_have_tag('input[@name=snippet_name]')
                _(html).must_have_tag('input[@id=snippet_name]')
                _(html).wont_have_tag('input[@value]')
              end

              it 'with a given value' do
                html = tag_helpers_app(
                  "<%= password_field_tag(:snippet_name, value: 'some-value') %>"
                )

                _(html).must_have_tag('input[@value="some-value"]')
                _(html).must_have_tag(
                  'input.text[@type=password][@class=text][@id=snippet_name][@name=snippet_name]'
                )
              end

              it 'with a custom id attribute' do
                html = tag_helpers_app("<%= password_field_tag(:snippet_name, id: 'some-id') %>")

                _(html).must_have_tag('input[@id="some-id"]')
                _(html).must_have_tag(
                  'input.text[@type=password][@class=text][@id="some-id"][@name=snippet_name]'
                )
              end

              it 'with a merged class attribute' do
                html = tag_helpers_app('<%= password_field_tag(:snippet_name, class: :big ) %>')

                _(html).must_have_tag('input[@class="big text"]')
                _(html).must_have_tag(
                  'input.text[@type=password][@id=snippet_name][@name=snippet_name]'
                )
              end

              it 'with a :title attribute when :ui_hint is passed' do
                html = tag_helpers_app("<%= password_field_tag(:name, ui_hint: 'UI-HINT') %>")

                _(html).must_have_tag('input[@title="UI-HINT"]')
                _(html).must_have_tag(
                  'input.text[@type=password][@class=text][@id=name][@name=name]'
                )
              end

              it 'with a :size & :maxlength attributes when passed' do
                html = tag_helpers_app(
                  %{<%= password_field_tag(:snippet_name, maxlength: 15, size: '20') %>}
                )

                _(html).must_have_tag('input[@maxlength="15"][@size="20"]')
                _(html).must_have_tag(
                  'input.text[@type=password][@class=text][@id=snippet_name][@name=snippet_name]'
                )
              end

              it 'with content :disabled => true' do
                html = tag_helpers_app('<%= password_field_tag(:snippet_name, disabled: true) %>')

                _(html).must_have_tag('input[@disabled=disabled]')
                _(html).must_have_tag(
                  'input.text[@type=password][@class=text][@id=snippet_name][@name=snippet_name]'
                )
              end
            end
            # /renders a basic password field tag
          end
          # /#password_field_tag
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
