# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#file_field_tag' do
            describe 'basic rendering' do
              it 'renders minimal field with name only' do
                _(tag_helpers_app('<%= file_field_tag(:attachment) %>'))
                  .must_equal(
                    %(<input class="file" id="attachment" name="attachment" type="file">\n)
                  )
              end

              it 'handles nil attributes gracefully' do
                _(tag_helpers_app('<%= file_field_tag(:attachment, nil) %>'))
                  .must_equal(
                    %(<input class="file" id="attachment" name="attachment" type="file">\n)
                  )
              end
            end
            # /basic rendering

            describe 'renders a file field tag' do
              it 'when only one attribute is passed' do
                html = tag_helpers_app('<%= file_field_tag(:attachment) %>')

                _(html).must_equal(
                  %(<input class="file" id="attachment" name="attachment" type="file">\n)
                )
                _(html).must_have_tag('input[@type=file]')
                _(html).must_have_tag('input[@class=file]')
                _(html).must_have_tag('input[@id=attachment]')
                _(html).must_have_tag('input[@name=attachment]')
                _(html).wont_have_tag('input[@value]')
              end

              it 'without the value attribute when passed' do
                html = tag_helpers_app("<%= file_field_tag(:photo, value: 'some-value') %>")

                _(html).must_equal(%(<input class="file" id="photo" name="photo" type="file">\n))
                _(html).wont_have_tag('input[@value]')
                _(html).must_have_tag('input[@type=file][@class=file][@id=photo][@name=photo]')
              end

              it 'with a custom id attribute' do
                html = tag_helpers_app("<%= file_field_tag(:photo, id: 'some-id') %>")

                _(html).must_have_tag('input[@id="some-id"]')
                _(html).must_have_tag('input[@type=file][@class=file][@name=photo]')
              end

              it 'with a merged class attribute' do
                html = tag_helpers_app('<%= file_field_tag(:photo, class: :big ) %>')

                _(html).must_have_tag('input[@class="big file"]')
                _(html).must_have_tag('input[@type=file][@id=photo][@name=photo]')
              end

              it 'with a :title attribute when :ui_hint is passed' do
                html = tag_helpers_app("<%= file_field_tag(:photo, ui_hint: 'UI-HINT') %>")

                _(html).must_have_tag('input[@title="UI-HINT"]')
                _(html).must_have_tag('input[@type=file][@class=file][@id=photo][@name=photo]')
              end

              it 'with :disabled => true' do
                html = tag_helpers_app('<%= file_field_tag(:photo, disabled: true) %>')

                _(html).must_have_tag('input[@disabled=disabled]')
                _(html).must_have_tag('input[@type=file][@class=file][@id=photo][@name=photo]')
              end

              it 'with an :accept attribute when :accept is passed' do
                html = tag_helpers_app(
                  "<%= file_field_tag(:photo, accept: 'image/png,image/gif,image/jpeg' ) %>"
                )

                _(html).must_have_tag('input[@accept="image/png,image/gif,image/jpeg"]')
                _(html).must_have_tag('input[@type=file][@class=file][@id=photo][@name=photo]')
              end
            end
            # /renders a basic file field tag
          end
          # / #file_field_tag
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
