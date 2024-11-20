# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#capture_html' do
            describe 'with ERB render engine' do
              it 'captures embedded tags in block output' do
                _(tag_app(%{<%= capture_html { tag(:p, 'Content') } %>}))
                  .must_equal "<p>Content</p>\n"
              end

              it 'captures direct block yield output' do
                _(tag_app(%{<%= capture_html { 'Content' } %>}))
                  .must_equal "Content"
              end

              it 'captures nested tag structures' do
                _(tag_app(%{<%= capture_html { tag(:div) { tag(:p, 'Nested') } } %>}))
                  .must_equal "<div>\n<p>Nested</p>\n</div>\n"
              end

              it 'handles empty blocks' do
                _(tag_app(%{<%= capture_html {} %>})).must_equal ''
              end
            end
            # /with ERB render engine

            describe 'with HAML render engine' do
              let(:haml_app) do
                Class.new(Roda) do
                  plugin :render, engine: 'haml'
                  plugin :tags

                  # Mock HAML-specific methods for testing
                  def is_haml?; true; end
                  def block_is_haml?(block); true; end
                  def capture_haml(*args, &block)
                    # Directly yield the block instead of calling capture_html
                    # to prevent recursion error
                    yield(*args).to_s
                  end
                end
              end

              let(:instance) { haml_app.new({}) }

              it 'captures embedded tags in block output' do
                _(tag_haml_app(%{= capture_html { tag(:div, 'Content') }}))
                  .must_equal "<div>\nContent\n</div>\n\n\n"
              end

              it 'captures content when block is haml' do
                _(instance.capture_html { "HAML content" })
                  .must_equal "HAML content"
              end

              it 'captures tag content in HAML context' do
                _(instance.capture_html { instance.tag(:div, 'HAML div') })
                  .must_equal "<div>\nHAML div\n</div>\n"
              end

              it 'handles non-HAML blocks in HAML context' do
                def instance.block_is_haml?(block); false; end

                _(instance.capture_html { "Direct content" })
                  .must_equal "Direct content"
              end

              it 'passes arguments through to the block' do
                res = instance.capture_html('arg1', 'arg2') do |a, b|
                  "Args: #{a}, #{b}"
                end
                _(res).must_equal "Args: arg1, arg2"
              end
            end
            # /with HAML render engine

            describe 'with no template engine' do
              let(:plain_app) do
                Class.new(Roda) do
                  plugin :tags
                  def is_haml?; false; end
                end
              end

              let(:instance) { plain_app.new({}) }

              it 'returns direct block output' do
                _(instance.capture_html { "Plain content" })
                  .must_equal "Plain content"
              end

              it 'handles tag helpers without template' do
                _(instance.capture_html { instance.tag(:span, "Test") })
                  .must_equal "<span>Test</span>\n"
              end
            end
            # /with no template engine
          end
          # /#capture_html
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
