# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#checkbox_tag' do
            describe 'renders a checkbox tag' do
              it 'when only one attribute is passed' do
                html = tag_helpers_app('<%= checkbox_tag :accept %>')

                _(html).must_have_tag('input.checkbox[@type=checkbox]')
                _(html).must_have_tag('input[@type=checkbox][@class=checkbox][@value="1"]')
                _(html).must_have_tag('input[@type=checkbox][@id=accept][@name=accept]')
              end

              it 'with a value' do
                html = tag_helpers_app("<%= check_box_tag :rock, value: 'rock music' %>")

                _(html).must_have_tag('input.checkbox[@type=checkbox][@value="rock music"]')
                _(html).must_have_tag('input.checkbox[@id=rock][@name=rock]')
              end

              it 'with a custom id attribute' do
                html = tag_helpers_app("<%= check_box_tag :rock, id: 'some-id' %>")

                _(html).must_have_tag('input[@type=checkbox][@id="some-id"]')
                _(html).must_have_tag('input.checkbox[@name=rock][@value="1"]')
              end

              it 'with a merged class attribute' do
                html = tag_helpers_app("<%= check_box_tag :rock, class: 'small' %>")

                _(html).must_have_tag('input[@type=checkbox][@class="checkbox small"]')
                _(html).must_have_tag('input[@type=checkbox][@id=rock][@name=rock][@value="1"]')
              end

              it 'with a :title attribute when :ui_hint is passed' do
                html = tag_helpers_app("<%= check_box_tag :rock, ui_hint: 'UI-HINT' %>")

                _(html).must_have_tag('input.checkbox[@type=checkbox][@title="UI-HINT"]')
                _(html).must_have_tag('input.checkbox[@type=checkbox][@name=rock][@value="1"]')
              end

              it 'with :checked true' do
                html = tag_helpers_app('<%= check_box_tag :rock, checked: true %>')

                _(html).must_have_tag('input.checkbox[@type=checkbox][@checked=checked]')
                _(html).must_have_tag('input[@type=checkbox][@id=rock][@name=rock][@value="1"]')
              end

              it 'with :disabled true' do
                html = tag_helpers_app('<%= check_box_tag :rock, disabled: true %>')

                _(html).must_have_tag('input.checkbox[@type=checkbox][@disabled=disabled]')
                _(html).must_have_tag('input[@type=checkbox][@id=rock][@name=rock][@value="1"]')
              end
            end
            # /renders a checkbox tag
          end
          # / #check_box_tag
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
