# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#select_tag' do
            describe 'renders a select tag' do
              it 'from a Hash' do
                html = tag_helpers_app("<%= select_tag(:ltrs, {a: 'A', b: 'B'}) %>")

                # _(html).must_equal ""
                _(html).must_have_tag('select#ltrs[@name=ltrs] > option[@value=a]', 'A')
                _(html).must_have_tag('select#ltrs[@name=ltrs] > option[@value=b]', 'B')
              end

              it 'from an Array' do
                html = tag_helpers_app("<%= select_tag(:ltrs, [[:a, 'A'], [:b, 'B']]) %>")

                _(html).must_have_tag('select#ltrs[@name=ltrs] > option[@value=a]', 'A')
                _(html).must_have_tag('select#ltrs[@name=ltrs] > option[@value=b]', 'B')
              end

              it 'with the selected value' do
                html = tag_helpers_app(
                  "<%= select_tag(:ltrs, [[:a, 'A'], [:b, 'B']], selected: :a) %>"
                )

                _(html).must_have_tag('select#ltrs[@name=ltrs]')
                _(html).must_have_tag('select > option[@value=a][@selected=selected]', 'A')
                _(html).must_have_tag('select > option[@value=b]', 'B')
              end

              it 'with multiple selected values' do
                html = tag_helpers_app(
                  "<%= select_tag(:ltrs, [[:a, 'A'], [:b, 'B']], selected: [:a,'b'] ) %>"
                )

                _(html).must_have_tag('select#ltrs[@name="ltrs[]"][@multiple=multiple]')
                _(html).must_have_tag('select > option[@value=a][@selected=selected]', 'A')
                _(html).must_have_tag('select > option[@value=b][@selected=selected]', 'B')
              end

              it 'with :multiple => true' do
                html = tag_helpers_app(
                  "<%= select_tag(:ltrs, [[:a, 'A'], [:b, 'B']], multiple: true) %>"
                )

                _(html).must_have_tag('select#ltrs[@name="ltrs[]"][@multiple=multiple]')
                _(html).must_have_tag('select > option[@value=a]', 'A')
                _(html).must_have_tag('select > option[@value=b]', 'B')
              end

              it 'as disabled with :disabled => true' do
                html = tag_helpers_app(
                  "<%= select_tag(:ltrs, [[:a, 'A'], [:b, 'B']], disabled: true ) %>"
                )

                _(html).must_have_tag('select#ltrs[@name=ltrs][@disabled=disabled]')
                _(html).must_have_tag('select > option[@value=a]', 'A')
                _(html).must_have_tag('select > option[@value=b]', 'B')
              end

              it 'with a custom id' do
                html = tag_helpers_app(
                  "<%= select_tag(:ltrs, [[:a, 'A'], [:b, 'B']], id: 'my-ltrs') %>"
                )

                _(html).must_have_tag('select#my-ltrs[@name=ltrs]')
                _(html).must_have_tag('select > option[@value=a]', 'A')
                _(html).must_have_tag('select > option[@value=b]', 'B')
              end

              it 'with a custom class' do
                html = tag_helpers_app(
                  "<%= select_tag(:ltrs, [[:a, 'A'], [:b, 'B']], class: 'funky-select') %>"
                )

                _(html).must_have_tag('select#ltrs[@name=ltrs][@class="funky-select"]')
                _(html).must_have_tag('select > option[@value=a]', 'A')
                _(html).must_have_tag('select > option[@value=b]', 'B')
              end

              it 'with prompt => true' do
                html = tag_helpers_app(
                  "<%= select_tag(:ltrs, [[:a, 'A'], [:b, 'B']], prompt: true ) %>"
                )

                _(html).must_have_tag('select#ltrs[@name=ltrs]')
                _(html)
                  .must_have_tag('select > option[@value=""][@selected=selected]', '- Select -')
                _(html).must_have_tag('select > option[@value=a]', 'A')
                _(html).must_have_tag('select > option[@value=b]', 'B')
              end

              it 'with a custom prompt' do
                opts = [[:a, 'A'], [:b, 'B']]
                html = tag_helpers_app(
                  "<%= select_tag(:ltrs, #{opts}, prompt: 'Letters', selected: 'a') %>"
                )
                _(html).must_have_tag('select#ltrs[@name=ltrs]')
                _(html).must_have_tag('select#ltrs > option[@value=""]', 'Letters')
                _(html).must_have_tag('select#ltrs > option[@value=a][@selected=selected]', 'A')
                _(html).must_have_tag('select#ltrs > option[@value=b]', 'B')
              end
            end
            # /renders a select tag
          end
          # / #select_tag
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
