# frozen_string_literal: false

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#merge_classes' do
            it 'correctly handles being passed empty arrays' do
              _(tag_app('<% @a={ class: [] } %><%= merge_classes(@a[:class], []) %>')).must_equal ''
            end

            it 'correctly handles being passed nil attrs and an empty array' do
              _(tag_app('<%= merge_classes(nil, []) %>')).must_equal ''
            end

            it 'correctly handles being passed nil values only' do
              _(tag_app('<%= merge_classes(nil, nil) %>')).must_equal ''
            end

            it 'correctly handles being passed empty hash values only' do
              _(tag_app('<%= merge_classes({}, {}) %>')).must_equal ''
            end

            it 'correctly handles being passed nil & empty array' do
              _(tag_app('<% @a={ class: nil   } %><%= merge_classes(@a[:class], []) %>'))
                .must_equal ''

              _(tag_app('<% @a={ class: nil   } %><%= merge_classes(@a[:class], nil) %>'))
                .must_equal ''

              _(tag_app('<% @a={ class: nil   } %><%= merge_classes(@a[:class], [nil]) %>'))
                .must_equal ''

              _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], nil) %>'))
                .must_equal ''

              _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], [nil]) %>'))
                .must_equal ''

              _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], [:alert]) %>'))
                .must_equal 'alert'

              _(tag_app('<% @a={ class: [nil] } %><%= merge_classes(@a[:class], [:alert, nil]) %>'))
                .must_equal 'alert'
            end

            it 'correctly handles removing duplicate values' do
              _(tag_app('<%= merge_classes({ class: :alert }, :alert) %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: :alert }, [:alert]) %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: [:alert] }, :alert) %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: [:alert] }, [:alert]) %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: "alert" }, :alert) %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: "alert" }, [:alert]) %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: ["alert"] }, [:alert]) %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: "alert" }, "alert") %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: "alert" }, ["alert"]) %>'))
                .must_equal 'alert'

              _(tag_app('<%= merge_classes({ class: ["alert"] }, ["alert"]) %>'))
                .must_equal 'alert'
            end

            it 'correctly merges the given classes when passed an empty array & array[strings]' do
              html = tag_app(
                '<% @a={ class: [] } %><%= merge_classes(@a[:class], ["alert", "alert-info"]) %>'
              )

              _(html).must_equal 'alert alert-info'
            end

            it 'correctly merges the given classes when passed nil & one with array[strings]' do
              html = tag_app(
                '<% @a={ class: nil } %><%= merge_classes(@a[:class], ["alert", "alert-info"]) %>'
              )

              _(html).must_equal 'alert alert-info'

              html = tag_app(
                '<% @a={ class: [nil] } %><%= merge_classes(@a[:class], ["alert", "alert-info"]) %>'
              )

              _(html).must_equal 'alert alert-info'
            end

            it 'correctly merges the given classes when passed arrays with strings' do
              code = '<% @a={ class: ["alert"] } %>'
              code << '<%= merge_classes(@a[:class], ["alert", "alert-info"]) %>'

              _(tag_app(code)).must_equal 'alert alert-info'
            end

            it 'correctly merges the given classes when passed string & array' do
              code = '<% @a={ class: "alert" } %>'
              code << '<%= merge_classes(@a[:class], ["alert", "alert-danger"]) %>'

              _(tag_app(code)).must_equal 'alert alert-danger'
            end

            it 'correctly merges the given classes when passed symbol & array' do
              code = '<% @a={ class: :alert } %>'
              code << '<%= merge_classes(@a[:class], ["alert", "alert-danger"]) %>'

              _(tag_app(code)).must_equal 'alert alert-danger'
            end

            it 'correctly merges the given classes when passed array[symbol] & array' do
              code = '<% @a={ class: [:alert, "error"] } %>'
              code << '<%= merge_classes(@a[:class], ["alert", "alert-danger"]) %>'

              _(tag_app(code)).must_equal 'alert alert-danger error'
            end

            it 'correctly merges the given classes when passed array[symbol] & :symbol' do
              code = '<% @a={ class: [:alert] } %><%= merge_classes(@a[:class], :text) %>'

              _(tag_app(code)).must_equal 'alert text'
            end

            it 'correctly merges the given classes when passed string & :symbol' do
              code = '<% @a={ class: "alert" } %><%= merge_classes(@a[:class], :text) %>'

              _(tag_app(code)).must_equal 'alert text'
            end

            it 'correctly merges the given classes when passed :symbol & :symbol' do
              code = '<% @a={ class: :alert } %><%= merge_classes(@a[:class], :text) %>'

              _(tag_app(code)).must_equal 'alert text'

              code = '<% @a={ class: :"alert-info" } %><%= merge_classes(@a[:class], :text) %>'

              _(tag_app(code)).must_equal 'alert-info text'
            end
          end
          # /#merge_classes
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
