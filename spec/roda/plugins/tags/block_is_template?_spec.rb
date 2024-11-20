# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#block_is_template?' do
            let(:erbapp) do
              Class.new(Roda) do
                plugin :tags
                plugin :render, engine: 'erb'

                route do |r|
                  r.root do
                    render(inline: 'Test')
                  end
                end
              end
            end

            let(:instance) { erbapp.new({}) }

            describe 'with ERB render engine' do
              it 'returns true for blocks from ERB templates' do
                result = instance.render(inline: '<%= "Test" %>')
                assert_equal 'Test', result.strip
              end

              it 'returns false for an ERB block' do
                erb_block = proc { '<%= "Test" %>' }
                refute instance.send(:block_is_template?, erb_block)
              end
            end
            # /with ERB render engine

            describe 'with regular blocks' do
              it 'returns false for non-template blocks' do
                regular_block = proc { 'hello' }

                refute instance.send(:block_is_template?, regular_block)
              end

              it 'returns false for nil' do
                refute instance.send(:block_is_template?, nil)
              end
            end

            describe 'with HAML render engine', if: defined?(Haml) do
              let(:haml_app) do
                Class.new(Roda) do
                  plugin :tags
                  plugin :render, engine: 'haml'

                  route do |r|
                    r.root do
                      render(inline: '%p Test')
                    end
                  end
                end
              end

              let(:haml_instance) { haml_app.new({}) }

              it 'returns true for blocks from HAML templates' do
                result = haml_instance.render(inline: '%p Test')
                assert_equal '<p>Test</p>', result.strip
              end

              it 'returns false for a HAML block' do
                haml_block = proc { '%p Test' }
                refute haml_instance.send(:block_is_template?, haml_block)
              end
            end
            # /with HAML render engine
          end
          # /#block_is_template?
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
