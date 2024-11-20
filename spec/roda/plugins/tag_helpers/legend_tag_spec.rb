# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#legend_tag' do
            describe 'renders a legend tag' do
              it 'with one attribute' do
                _(tag_helpers_app("<%= legend_tag('User Details') %>"))
                  .must_have_tag('legend', 'User Details')
              end

              it 'with an :id attribute' do
                _(tag_helpers_app("<%= legend_tag('User Details', id: 'some-id') %>"))
                  .must_have_tag('legend#some-id', 'User Details')
              end

              it 'with :class attribute' do
                _(tag_helpers_app("<%= legend_tag('User Details', class: 'some-class') %>"))
                  .must_have_tag('legend[@class=some-class]', 'User Details')
              end

              it 'when a nil value was passed' do
                _(tag_helpers_app('<%= legend_tag(nil) %>')).must_have_tag('legend', '')
              end
            end
            # /renders a legend tag
          end
          # / #legend_tag
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
