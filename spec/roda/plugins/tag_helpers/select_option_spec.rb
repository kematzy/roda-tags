# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#select_option' do
            describe 'renders a select option tag' do
              it 'with params' do
                _(tag_helpers_app("<%= select_option('a', 'Letter A') %>"))
                  .must_have_tag('option[@value=a]', 'Letter A')
              end

              it 'handle a missing key value' do
                _(tag_helpers_app("<%= select_option('on', nil) %>"))
                  .must_have_tag('option[@value=on]', 'On')
              end

              it 'with :selected => true' do
                _(tag_helpers_app("<%= select_option('a', 'Letter A', selected: true) %>"))
                  .must_have_tag('option[@value=a][@selected=selected]', 'Letter A')
              end

              it 'without selected when given :selected => false' do
                html = tag_helpers_app("<%= select_option('a', 'Letter A', selected: false) %>")
                _(html).must_have_tag('option[@value=a]', 'Letter A')
                _(html).wont_have_tag('option[@selected=selected]')
              end
            end
            # /renders a select option tag
          end
          # / #select_option
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
