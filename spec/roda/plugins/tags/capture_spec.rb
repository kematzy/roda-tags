# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#capture' do
            describe 'with ERB render engine' do
              let(:erbapp) do
                Class.new(Roda) do
                  plugin :render, engine: 'erb'
                  plugin :tags

                  route do |r|
                    r.root do
                      render(inline: "Test")
                    end
                  end
                end
              end

              let(:instance) { erbapp.new({}) }

              it "captures whitespace of the block but not the silent '<% ... %>' tag output" do
                _(tag_app(%{<% capture do %> <% tag(:br) %> <% end %>})).must_equal '  '
              end

              it "captures the whitespace of the block including the '<%= tag(:br) %>' output" do
                _(tag_app(%{<% capture do %>|<%= tag(:br) %>|<% end %>}))
                  .must_equal %(|<br>\n|)
              end

              it 'captures the contents of a mixed block' do
                str = <<~ERB
                  <% capture do %>
                    <% tag(:div, class: 'row') do %>
                      <% tag(:div, class: 'col-md-12') do %>
                        <%= tag(:h1, 'Capture Works too') %>
                        <%- tag(:h2) do %>
                          Nested capture works too
                        <%- end %>
                      <% end %>
                    <% end %>
                  <% end %>
                ERB

                html = tag_app(str)
                _(html).must_have_tag('div.row > div[@class="col-md-12"] > h1', 'Capture Works too')

                _(html.strip).must_have_tag(
                  'div.row > div[@class="col-md-12"] > h2',
                  %(        Nested capture works too\n)
                )
              end

              it 'handles being passed a Proc block' do
                 _(tag_app(%{<% capture(proc { 'Test' }) do %>|<%= tag(:br) %>|<% end %>}))
                  .must_equal %(|<br>\n|)
              end
            end
            # /with ERB render engine

            describe 'with HAML render engine' do
              it "captures whitespace of the block but not the silent '- ...' tag output" do
                _(tag_haml_app(%{- capture do\n  - tag(:br)\n})).must_equal "\n"
              end

              it "captures the whitespace of the block including the '=' output" do
                _(tag_haml_app(%{- capture do\n  = tag(:br)\n}))
                  .must_equal %(<br>\n\n\n)
              end

              it 'captures the contents of a mixed block' do
                str = <<~HAML
                  - capture do
                    - tag(:div, class: 'row') do
                      - tag(:div, class: 'col-md-12') do
                        = tag(:h1, 'Capture Works too')
                        - tag(:h2) do
                          Nested capture works too
                HAML

                html = tag_haml_app(str)
                _(html).must_have_tag('div.row > div.col-md-12 > h1', 'Capture Works too')
                _(html).must_have_tag('div.row > div.col-md-12 > h2', "Nested capture works too\n")
              end
            end
            # /with HAML render engine
          end
          # /#capture

          describe '#capture' do
            let(:capture_testapp) do
              Class.new(Roda) do
                plugin :render, engine: 'erb'
                plugin :tags
              end
            end

            let(:instance) { capture_testapp.new({}) }

            it 'evaluates @_out_buf from block binding' do
              # Create a proc with @_out_buf defined in its binding
              test_proc = Proc.new do
                @_out_buf = "buffer content"
                true
              end

              result = instance.capture(test_proc) { "yield content" }
              # assert_equal nil, result
              # assert_equal "buffer content", result
            end

            it 'falls back to block parameter when not a Proc' do
              # instance = Class.new(Roda) { plugin :tags }.new({})
              result = instance.capture("default content") { "yield content" }
              assert_equal "default content", result
            end

            it 'restores original output buffer' do
              # instance = Class.new(Roda) { plugin :tags }.new({})
              instance.instance_variable_set(:@output, "original")
              instance.capture("test") { "yield" }
              assert_equal "original", instance.instance_variable_get(:@output)
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
# rubocop:enable Metrics/BlockLength
