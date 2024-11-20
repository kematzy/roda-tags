# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#fieldset_tag' do
            describe 'renders a fieldset tag' do
              it 'without a block' do
                html = tag_helpers_app('<% fieldset_tag(:actor) %>')

                _(html).must_have_tag('fieldset#fieldset-actor')
                _(html).must_have_tag('fieldset[@id=fieldset-actor]')
              end

              it 'with a legend and a block' do
                str = <<~ERB
                  <% fieldset_tag 'Users' do %>
                    <p><%= text_field_tag 'name' %></p>
                  <% end %>
                ERB
                html = tag_helpers_app(str)

                _(html).must_have_tag('fieldset#fieldset-users > legend', 'Users')
                _(html).must_have_tag(
                  'fieldset#fieldset-users > p > input#name[@type=text][@id=name][@name=name]'
                )
                # _(html).must_equal(
                #   %Q{<fieldset id="fieldset-users">\n  <legend>Users</legend>\n
                #   <p><input class="text" id="name" name="name" type="text">\n</p></fieldset>\n}
                # )
              end

              it 'with class and legend' do
                html = tag_helpers_app(
                  %{<% fieldset_tag(:actor, legend: 'Users', class: "legend-class") %>}
                )

                _(html).must_have_tag('fieldset#fieldset-actor.legend-class > legend', 'Users')
                _(html).must_have_tag('fieldset[@id=fieldset-actor] > legend', 'Users')
              end

              it 'without :id when :id => false' do
                html = tag_helpers_app(%{<% fieldset_tag(:actor, legend: 'Users', id: false) %>})

                _(html).must_have_tag('fieldset > legend', 'Users')

                html = tag_helpers_app(%{<% fieldset_tag('Users', id: false) %>})
                _(html).must_have_tag('fieldset > legend', 'Users')
                _(html).wont_have_tag('fieldset[@id]')
              end

              it "with :id attribute as 'fieldset' when passed nil as first args" do
                html = tag_helpers_app(%{<% fieldset_tag(nil, legend: 'Users', class: 'big') %>})

                _(html).must_have_tag('fieldset.big > legend', 'Users')
              end

              it 'with a block' do
                str = <<~ERB
                  <% fieldset_tag(:actor, :legend => 'Users', :class => "legend-class") do %>
                    <p><%= text_field_tag :name %></p>
                  <% end %>
                ERB
                html = tag_helpers_app(str)

                _(html).must_have_tag('fieldset#fieldset-actor.legend-class > legend', 'Users')
                _(html).must_have_tag('fieldset > p > input#name.text[@name=name]')
              end
            end
            # /renders a fieldset tag
          end
          # / #fieldset_tag
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
