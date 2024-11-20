# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#radio_button_tag' do
            describe 'renders a radio input tag' do
              it 'with a :name attribute only' do
                html = tag_helpers_app('<%= radio_button_tag :accept %>')

                _(html).must_have_tag('input[@type=radio][@id=accept_1][@name=accept][@value="1"]')
              end

              it 'with a value' do
                html = tag_helpers_app("<%= radio_button_tag :rock, value: 'rock music' %>")

                _(html).must_have_tag(
                  'input[@type=radio][@id="rock_rock-music"][@name=rock][@value="rock music"]'
                )
              end

              it 'with a custom id attribute' do
                html = tag_helpers_app("<%= radio_button_tag :rock, id: 'some-id' %>")

                _(html).must_have_tag(
                  'input.radio[@type=radio][@id="some-id_1"][@name=rock][@value="1"]'
                )
              end

              it 'with a merged class attribute' do
                html = tag_helpers_app("<%= radio_button_tag :rock, class: 'small' %>")

                _(html).must_have_tag(
                  'input[@type=radio][@class="radio small"][@id="rock_1"][@value="1"]'
                )
              end

              it 'with a :title attribute when :ui_hint is passed' do
                html = tag_helpers_app("<%= radio_button_tag :rock, ui_hint: 'HINT' %>")

                _(html)
                  .must_have_tag('input.radio[@type=radio][@title="HINT"][@id=rock_1][@name=rock]')
              end

              it 'with :checked true' do
                html = tag_helpers_app('<%= radio_button_tag :rock, checked: true %>')

                _(html).must_have_tag('input.radio[@type=radio][@checked=checked]')
                _(html).must_have_tag('input.radio[@type=radio][@id=rock_1][@name=rock]')
              end

              it 'as disabled when :disabled true' do
                html = tag_helpers_app('<%= radio_button_tag :rock, disabled: true %>')

                _(html).must_have_tag('input.radio[@type=radio][@disabled=disabled]')
                _(html).must_have_tag('input.radio[@type=radio][@id=rock_1][@name=rock]')
              end
            end
            # /renders a radio input tag
          end
          # / #radio_button_tag
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
