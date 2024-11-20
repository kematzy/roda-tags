# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#image_submit_tag' do
            describe 'renders an input[@type=image] tag' do
              it 'should return a simple tag' do
                html = tag_helpers_app('<%= image_submit_tag("/img/login.png") %>')

                _(html).must_have_tag('input[@type=image][@src="/img/login.png"]')
              end

              it 'with custom class' do
                html = tag_helpers_app('<%= image_submit_tag("/img/buy.png", class: "buy") %>')

                _(html).must_have_tag('input.buy[@type=image][@src="/img/buy.png"]')
              end

              it 'as disabled when disabled: true' do
                html = tag_helpers_app('<%= image_submit_tag("/img/buy.png", disabled: true) %>')

                _(html).must_have_tag('input[@type=image][@disabled=disabled][@src="/img/buy.png"]')
              end
            end
            # /renders an input[@type=image] tag
          end
          # / #image_submit_tag
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
