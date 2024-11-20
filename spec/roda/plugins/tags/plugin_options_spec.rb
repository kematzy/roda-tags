# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe ':opts - default options' do
          before do
            @a = Class.new(Roda)
            @a.plugin(:tags)
          end

          describe 'self.#tags_opts (plugin :tags)' do
            it 'returns the default settings' do
              expected = {
                tag_output_format_is_xhtml: false,
                tag_add_newlines_after_tags: true,
                orig_opts: {
                  tag_output_format_is_xhtml: false,
                  tag_add_newlines_after_tags: true
                }
              }
              _(@a.tags_opts).must_equal(expected)
            end

            it ':tag_output_format_is_xhtml => false' do
              _(@a.tags_opts[:tag_output_format_is_xhtml]).must_equal(false)
            end

            it ':tag_add_newlines_after_tags => true' do
              _(@a.tags_opts[:tag_add_newlines_after_tags]).must_equal(true)
            end

            it ':orig_opts => {}' do
              _(@a.tags_opts[:orig_opts])
                .must_equal({
                              tag_output_format_is_xhtml: false,
                              tag_add_newlines_after_tags: true
                            })
            end
          end
          # /self.#tags_opts (plugin :tags)
        end
        # /:opts - default options

        describe ':opts - custom options' do
          before do
            @b = Class.new(Roda)
            @b.plugin(:tags, tag_output_format_is_xhtml: true, tag_add_newlines_after_tags: false)
          end

          describe 'self.#tags_opts (plugin :tags)' do
            it 'returns the custom settings' do
              expected = {
                tag_output_format_is_xhtml: true,
                tag_add_newlines_after_tags: false,
                orig_opts: {
                  tag_output_format_is_xhtml: true,
                  tag_add_newlines_after_tags: false
                }
              }
              _(@b.tags_opts).must_equal(expected)
            end

            it ':tag_output_format_is_xhtml => true' do
              _(@b.tags_opts[:tag_output_format_is_xhtml]).must_equal(true)
            end

            it ':tag_add_newlines_after_tags => false' do
              _(@b.tags_opts[:tag_add_newlines_after_tags]).must_equal(false)
            end

            it ':orig_opts => {}' do
              _(@b.tags_opts[:orig_opts])
                .must_equal({
                              tag_output_format_is_xhtml: true,
                              tag_add_newlines_after_tags: false
                            })
            end
          end

          describe '#output_is_xhtml?' do
            it 'returns true' do
              html = tag_app(
                '<%= output_is_xhtml?.inspect %>',
                {},
                { tag_output_format_is_xhtml: true }
              )

              _(html).must_equal 'true'
            end
          end
          # /#output_is_xhtml?
        end
        # /:opts - custom options

        describe 'loading plugin twice' do
          before do
            @c = Class.new(Roda)
            @c.plugin(:tags, tag_output_format_is_xhtml: true, tag_add_newlines_after_tags: false)

            @d = Class.new(@c)
            @d.plugin(:tags, tag_output_format_is_xhtml: false)
          end

          it 'returns the custom options' do
            expected = {
              tag_output_format_is_xhtml: false,
              tag_add_newlines_after_tags: false,
              orig_opts: {
                tag_output_format_is_xhtml: false,
                tag_add_newlines_after_tags: false
              }
            }
            _(@d.tags_opts).must_equal(expected)
          end
        end
        # /loading plugin twice
      end
      # /plugin :tags
    end
    # /RodaTags
  end
  # /RodaPlugins
end
# /Roda
# rubocop:enable Metrics/BlockLength
