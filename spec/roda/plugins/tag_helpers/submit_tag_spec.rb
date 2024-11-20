# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#submit_tag' do
            describe 'renders a submit tag' do
              it 'without attributes' do
                html = tag_helpers_app('<%= submit_tag %>')

                _(html).must_equal(%(<input name="submit" type="submit" value="Save Form">\n))
                _(html).must_have_tag('input[@type=submit][@name=submit][@value="Save Form"]')
              end

              it 'with a custom value' do
                html = tag_helpers_app("<%= submit_tag('Custom Value') %>")

                _(html)
                  .must_have_tag('input[@type=submit][@name=submit][@value="Custom Value"]')
              end

              it 'with empty value when given a nil value' do
                html = tag_helpers_app('<%= submit_tag(nil) %>')

                _(html).must_have_tag('input[@type=submit][@name=submit][@value=""]')
                # _(html).wont_have_tag('input[@type=submit][@value]')
              end

              it 'with a custom class attribute' do
                html = tag_helpers_app("<%= submit_tag('Custom', class: 'some-class' ) %>")

                _(html).must_have_tag('input[@type=submit][@class="some-class"][@value="Custom"]')
                _(html).must_have_tag('input[@type=submit][@name=submit]')
              end

              it 'with :ui_hint => ...' do
                html = tag_helpers_app("<%= submit_tag(ui_hint: 'UI-HINT' ) %>")

                _(html).must_have_tag('input[@type=submit][@title="UI-HINT"]')
                _(html).must_have_tag('input[@type=submit][@name=submit][@value="Save Form"]')
              end

              it 'as disabled with disabled: true' do
                html = tag_helpers_app('<%= submit_tag(disabled: true ) %>')
                _(html).must_have_tag('input[@type=submit][@disabled=disabled][@value="Save Form"]')
              end
            end
            # /renders a submit tag
          end
          # / #submit_tag
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
