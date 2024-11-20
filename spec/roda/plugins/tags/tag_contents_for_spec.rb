# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#tag_contents_for' do
            it 'handles a single line tag with new lines true' do
              html = tag_app(%{<%= tag_contents_for(:option, 'content', true) %>})

              _(html).must_equal "\ncontent\n"
            end

            it 'handles a single line tag with new lines false' do
              html = tag_app(%{<%= tag_contents_for(:option, 'content', false) %>})

              _(html).must_equal 'content'
            end
          end
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
