# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#merge_attr_classes' do
            it 'merges the given classes' do
              _(tag_app('<%= merge_attr_classes({ class: "a b d" }, "c") %>'))
                .must_equal '{:class=>"a b c d"}' # "a b c d"
            end

            it 'merges the given classes and return only uniq classes' do
              _(tag_app('<%= merge_attr_classes({ class: "a b d" }, "a b") %>'))
                .must_equal '{:class=>"a b d"}' # "a b d"
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
