# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe 'private methods' do
            let(:erbapp) do
              Class.new(Roda) do
                plugin :render, engine: 'erb'
                plugin :tags
              end
            end

            let(:hamlapp) do
              Class.new(Roda) do
                plugin :render, engine: 'haml'
                plugin :tags
              end
            end

            describe '#erb_block?' do
              let(:instance) { erbapp.new({}) }

              it 'returns false for nil block' do
                refute instance.send(:erb_block?, nil)
              end

              it 'returns false for regular block' do
                refute instance.send(:erb_block?, proc { 'not ERB' })
              end

              it 'returns true for block with "<%= ... %>" tags' do
                # Create binding with __in_erb_template defined
                eval_binding = binding
                eval_binding.eval("__in_erb_template = true")
                # Create block that uses that binding
                block = eval("proc { '<%= \"ERB\" %>' }", eval_binding)

                assert instance.send(:erb_block?, block)
              end

              it 'returns true for ERB block' do
                # Create binding with __in_erb_template defined
                eval_binding = binding
                eval_binding.eval("__in_erb_template = true")
                # Create block that uses that binding
                block = eval("proc { }", eval_binding)

                assert instance.send(:erb_block?, block)
              end
            end
            # /#erb_block?

            describe '#haml_block?' do
              let(:instance) { hamlapp.new({}) }

              it 'returns false for nil block' do
                refute instance.send(:haml_block?, nil)
              end

              it 'returns false for regular block' do
                refute instance.send(:haml_block?, proc { 'not HAML' })
              end

              it 'returns true for HAML block' do
                # Create binding with _hamlout defined
                eval_binding = binding
                eval_binding.eval("_hamlout = true")

                # Create block that uses that binding
                block = eval("proc { '%p content' }", eval_binding)

                assert instance.send(:haml_block?, block)
              end
            end
            # /#haml_block?

            describe '#open_tag' do
              let(:instance_erb) { erbapp.new({}) }
              let(:instance_haml) { hamlapp.new({}) }

              it 'opens a basic tag' do
                _(instance_erb.send(:open_tag, :div)).must_equal '<div>'

                _(instance_haml.send(:open_tag, :div)).must_equal '<div>'
              end

              it 'opens a basic tag with :id & :class attributes' do
                _(instance_erb.send(:open_tag, :div, { class: 'btn', id: 'submit' }))
                  .must_equal '<div class="btn" id="submit">'

                _(instance_haml.send(:open_tag, :div, { class: 'btn', id: 'submit' }))
                  .must_equal '<div class="btn" id="submit">'
              end
            end
            # /#open_tag

            describe '#closing_tag' do
              let(:instance_erb) { erbapp.new({}) }
              let(:instance_haml) { hamlapp.new({}) }

              it 'closes a basic tag' do
                _(instance_erb.send(:closing_tag, :div)).must_equal "</div>\n"

                _(instance_haml.send(:closing_tag, :div)).must_equal "</div>\n"
              end

              it 'closes a span tag without a newline' do
                _(instance_erb.send(:closing_tag, :span))
                  .must_equal "</span>\n"

                _(instance_haml.send(:closing_tag, :span))
                  .must_equal "</span>\n"
              end
            end
            # /#closing_tag

            describe '#self_closing_tag' do
              let(:instance_erb) { erbapp.new({}) }
              let(:instance_haml) { hamlapp.new({}) }

              it 'closes a :br tag' do
                _(instance_erb.send(:self_closing_tag, :br, { newline: false }))
                  .must_equal '<br>'

                _(instance_haml.send(:self_closing_tag, :br))
                  .must_equal "<br>\n"
              end

              it 'closes a :img tag' do
                _(instance_erb.send(:self_closing_tag, :img, { src: 'test.jpg', newline: false }))
                  .must_equal '<img src="test.jpg">'

                _(instance_haml.send(:self_closing_tag, :img, { src: 'test.jpg', newline: true }))
                  .must_equal "<img src=\"test.jpg\">\n"
              end
            end
            # /#self_closing_tag

            describe '#tag_contents_for' do
              let(:instance_erb) { erbapp.new({}) }
              let(:instance_haml) { hamlapp.new({}) }

              it 'handles a multiline tag' do
                _(instance_erb.send(:tag_contents_for, :div, 'content'))
                  .must_equal "\ncontent\n"

                _(instance_haml.send(:tag_contents_for, :div, 'content'))
                  .must_equal "\ncontent\n"
              end

              it 'handles a single line tag with newlines' do
                _(instance_erb.send(:tag_contents_for, :span, 'text', true))
                  .must_equal "\ntext\n"

                _(instance_haml.send(:tag_contents_for, :span, 'text', true))
                  .must_equal "\ntext\n"
              end

              it 'handles a tag with basic content' do
                _(instance_erb.send(:tag_contents_for, :p, 'text'))
                  .must_equal 'text'

                _(instance_haml.send(:tag_contents_for, :p, 'text'))
                  .must_equal 'text'
              end
            end
            # /#tag_contents_for

            describe '#boolean_attribute?' do
              let(:instance_erb) { erbapp.new({}) }

              Roda::RodaPlugins::RodaTags::BOOLEAN_ATTRIBUTES.each do |m|
                it "returns true for '#{m}'" do
                  assert instance_erb.send(:boolean_attribute?, m)
                end
              end

              Roda::RodaPlugins::RodaTags::SELF_CLOSING_TAGS.each do |m|
                it "returns false for '#{m}'" do
                  refute instance_erb.send(:boolean_attribute?, m)
                end
              end
            end
            # /#boolean_attribute?

            describe '#self_closing_tag?' do
              let(:instance_erb) { erbapp.new({}) }

              Roda::RodaPlugins::RodaTags::SELF_CLOSING_TAGS.each do |m|
                it "returns true for '#{m}'" do
                  assert instance_erb.send(:self_closing_tag?, m)
                end
              end

              Roda::RodaPlugins::RodaTags::SINGLE_LINE_TAGS.each do |m|
                it "returns false for '#{m}'" do
                  refute instance_erb.send(:self_closing_tag?, m)
                end
              end
            end
            # /#self_closing_tag?

            describe '#single_line_tag?' do
              let(:instance_erb) { erbapp.new({}) }

              Roda::RodaPlugins::RodaTags::SINGLE_LINE_TAGS.each do |m|
                it "returns true for '#{m}'" do
                  assert instance_erb.send(:single_line_tag?, m)
                end
              end

              Roda::RodaPlugins::RodaTags::SELF_CLOSING_TAGS.each do |m|
                it "returns false for '#{m}'" do
                  refute instance_erb.send(:single_line_tag?, m)
                end
              end
            end
            # /#single_line_tag?

            describe '#multi_line_tag?' do
              let(:instance_erb) { erbapp.new({}) }

              Roda::RodaPlugins::RodaTags::MULTI_LINE_TAGS.each do |m|
                it "returns true for '#{m}'" do
                  assert instance_erb.send(:multi_line_tag?, m)
                end
              end

              Roda::RodaPlugins::RodaTags::SELF_CLOSING_TAGS.each do |m|
                it "returns false for '#{m}'" do
                  refute instance_erb.send(:multi_line_tag?, m)
                end
              end
            end
            # /#multi_line_tag?

            describe '#xhtml?' do
              before do
                @a = Class.new(Roda)
                @a.plugin(:tags, tag_output_format_is_xhtml: true)

                @b = Class.new(@a)
                @b.plugin(:tags, tag_output_format_is_xhtml: false)
              end

              it 'returns " />" end when true' do
                _(@a.new({}).send(:xhtml?)).must_equal ' />'
              end

              it 'returns ">" end when false' do
                _(@b.new({}).send(:xhtml?)).must_equal '>'
              end
            end
            # /#xhtml?

            describe '#add_newline?' do
              before do
                @a = Class.new(Roda)
                @a.plugin(:tags, tag_add_newlines_after_tags: true)

                @b = Class.new(@a)
                @b.plugin(:tags, tag_add_newlines_after_tags: false)
              end

              it 'returns "\\n" when true' do
                _(@a.new({}).send(:add_newline?)).must_equal "\n"
              end

              it 'returns "" when false' do
                _(@b.new({}).send(:add_newline?)).must_equal ''
              end
            end
            # /#add_newline?

            describe '#buffer_concat' do
              it 'TODO: add some tests'
            end
            # /#buffer_concat

            describe '#capture_block' do
              it 'TODO: add some tests'
            end
            # /#capture_block

            describe '#with_output_buffer' do
              it 'TODO: add some tests'
            end
            # /#with_output_buffer

            describe '#buffer?' do
              it 'TODO: add some tests'
            end
            # /#buffer?
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
