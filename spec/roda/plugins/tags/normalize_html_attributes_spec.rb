# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#normalize_html_attributes' do
            it 'should handle empty attrs' do
              _(tag_app('<%= normalize_html_attributes({}) %>')).must_equal ''
            end

            it 'handles basic attrs' do
              _(tag_app('<%= normalize_html_attributes({class: "alert"}) %>'))
                .must_equal ' class="alert"'
            end

            it 'handles data attrs' do
              html = tag_app(
                '<%= normalize_html_attributes({data: { b: :B, a: :A }, class: "alert"}) %>'
              )

              _(html).must_equal ' class="alert" data-a="A" data-b="B"'
            end

            it 'handles boolean attrs' do
              html = tag_app(
                '<%= normalize_html_attributes({data: {b: :B, a: :A}, selected: true }) %>'
              )

              _(html).must_equal ' data-a="A" data-b="B" selected="selected"'

              html = tag_app(
                '<%= normalize_html_attributes({data: {b: :B, a: :A}, selected: false}) %>'
              )

              _(html).must_equal ' data-a="A" data-b="B"'
            end
          end
          # /#normalize_html_attributes
        end
        # /InstanceMethods
      end
      # /plugin :tags
    end
    # /RodaTags
  end
  # /RodaPlugins
end
# /Roda
# rubocop:enable Metrics/BlockLength
