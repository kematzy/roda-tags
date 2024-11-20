# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#concat_content' do
            describe 'with ERB engine output' do
              it 'when using <% - returns a single output' do
                _(tag_app(%{<% concat_content('text') %>}))
                  .must_equal 'text'
              end

              it 'when using <%= - duplicates text output' do
                _(tag_app(%{<%= concat_content('text') %>}))
                  .must_equal 'texttext'
              end

              it 'handles nil input' do
                _(tag_app(%{<% concat_content(nil) %>}))
                  .must_equal ''
              end

              it 'handles numeric inputs' do
                _(tag_app(%{<% concat_content(123) %>}))
                  .must_equal '123'
              end

              it 'concatenates multiple calls' do
                _(tag_app(%{<% concat_content('A') %><% concat_content('B') %>}))
                  .must_equal 'AB'
              end

              it 'when setting a variable within a <% capture %><% end %> block' do
                _(tag_app(%{<% capture do %><% @r = concat_content('test') %><% end %>}))
                  .must_equal 'test'
              end

              it 'output "A" and concat_content()' do
                _(tag_app(%{<%= 'A' %> <% concat_content('test') %>}))
                  .must_equal 'A test'
              end

              describe 'nested content handling' do
                it 'works with capture blocks' do
                  template = <<~TEMPLATE
                    <% capture do %>
                      <% concat_content('level1') %>
                      <% capture do %>
                        <% concat_content('level2') %>
                      <% end %>
                    <% end %>
                  TEMPLATE

                  _(tag_app(template)).must_equal 'level1level2'
                end

                it 'works with tags and concat_content' do
                  template = <<~TEMPLATE
                    <% tag(:div) do %>
                      <% concat_content('inside div') %>
                    <% end %>
                  TEMPLATE

                  _(tag_app(template)).must_equal "<div>\ninside div\n</div>\n"
                end
              end
            end
            # /with ERB engine output

            describe 'with HAML engine output' do
              let(:haml_app) do
                Class.new(Roda) do
                  plugin :render, engine: 'haml'
                  plugin :tags

                  # Mock HAML-specific methods
                  def is_haml? = true

                  # Track haml_concat calls
                  def haml_concat(text)
                    @haml_outputs ||= []
                    @haml_outputs << text
                    text
                  end

                  def haml_outputs
                    @haml_outputs || []
                  end
                end
              end

              let(:instance) { haml_app.new({}) }

              it 'calls haml_concat when in HAML context' do
                instance.concat_content('test')
                _(instance.haml_outputs).must_include 'test'
              end

              it 'handles empty content in HAML context' do
                instance.concat_content('')
                _(instance.haml_outputs).must_include ''
              end

              it 'handles nil content in HAML context' do
                instance.concat_content(nil)
                _(instance.haml_outputs).must_include ''
              end

              it 'handles complex objects' do
                obj = Object.new
                def to_s = 'object'

                _(instance.concat_content(obj)).must_equal 'object'
              end

              it 'preserves content through HAML concat' do
                _(instance.concat_content('preserved'))
                  .must_equal 'preserved'
              end

              it 'processes multiple concat calls in HAML' do
                instance.concat_content('first')
                instance.concat_content('second')
                _(instance.haml_outputs).must_equal %w[first second]
              end

              it 'when using - returns a single output' do
                _(tag_haml_app(%{- concat_content('text')}))
                  .must_equal "text\n"
              end

              it 'when using <%= - duplicates text output' do
                _(tag_haml_app(%{= concat_content('text')}))
                  .must_equal "texttext\n\n"
              end
            end
            # /with HAML engine output

            describe 'with no template engine' do
              let(:plain_app) do
                Class.new(Roda) do
                  plugin :tags
                  # Ensure is_haml? returns false
                  def is_haml? = false
                end
              end
              let(:instance) { plain_app.new({}) }

              it 'returns text directly when no template engine is present' do
                _(instance.concat_content('hello')).must_equal 'hello'
              end

              it 'returns empty string when no input given' do
                _(instance.concat_content).must_equal ''
              end

              it 'handles nil input' do
                _(instance.concat_content(nil)).must_equal ''
              end
            end
            # /with no template engine
          end
          # /#concat_content
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
