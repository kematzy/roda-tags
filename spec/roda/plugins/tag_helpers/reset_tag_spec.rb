# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#reset_tag' do
            describe 'renders a reset tag' do
              it 'without attributes' do
                html = tag_helpers_app('<%= reset_tag %>')

                _(html).must_equal(%(<input name="reset" type="reset" value="Reset Form">\n))
                _(html).must_have_tag('input[@type=reset][@name=reset][@value="Reset Form"]')
              end

              it 'with custom value' do
                html = tag_helpers_app("<%= reset_tag('Custom Value') %>")

                _(html).must_have_tag('input[@type=reset][@name=reset][@value="Custom Value"]')
              end

              it 'with empty value when given a nil value' do
                html = tag_helpers_app('<%= reset_tag(nil) %>')

                _(html).must_have_tag('input[@type=reset][@name=reset][@value=""]')
              end

              it 'with a custom class attribute' do
                html = tag_helpers_app("<%= reset_tag(class: 'klass' ) %>")

                _(html).must_have_tag('input[@type=reset][@class="klass"][@name=reset]')
              end

              it 'with :ui_hint => ...' do
                html = tag_helpers_app("<%= reset_tag(ui_hint: 'UI-HINT' ) %>")

                _(html).must_have_tag('input[@type=reset][@title="UI-HINT"][@name=reset]')
                _(html).must_have_tag('input[@type=reset][@value="Reset Form"]')
              end

              it 'with :disabled => true' do
                html = tag_helpers_app("<%= reset_tag('Disabled', disabled: true ) %>")

                _(html).must_have_tag('input[@type=reset][@disabled=disabled][@value="Disabled"]')
              end
            end
            # /renders a reset tag
          end
          # / #reset_tag
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
