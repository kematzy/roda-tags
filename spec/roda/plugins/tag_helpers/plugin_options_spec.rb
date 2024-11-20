# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe ':opts - default options' do
          before do
            @a = Class.new(Roda)
            @a.plugin(:tag_helpers)
          end

          describe 'self.#tag_helpers_opts' do
            it 'returns the default settings' do
              expected = {
                tags_label_required_str: '<span>*</span>',
                tags_label_append_str: ':',
                tags_forms_default_class: '',
                orig_opts: {
                  tags_label_required_str: '<span>*</span>',
                  tags_label_append_str: ':',
                  tags_forms_default_class: ''
                }
              }
              _(@a.tag_helpers_opts).must_equal(expected)
            end
          end
          # /self.#tag_helpers_opts

          describe 'self.#tags_opts (plugin :tags)' do
            it 'returns :tag_output_format_is_xhtml => false' do
              _(@a.tags_opts[:tag_output_format_is_xhtml]).must_equal false
            end

            it 'returns :tags_label_required_str => "<span>*</span>"' do
              _(@a.tags_opts[:tags_label_required_str]).must_equal '<span>*</span>'
            end

            it 'returns :tags_forms_default_class => ""' do
              _(@a.tags_opts[:tags_forms_default_class]).must_equal ''
            end
          end
          # /self.#tags_opts (plugin :tags)
        end
        # /:opts - default options

        describe ':opts - custom options' do
          before do
            @b = Class.new(Roda)
            @b.plugin(:tag_helpers,
                      tag_output_format_is_xhtml: true,
                      tags_label_required_str: 'REQUIRED',
                      tags_forms_default_class: 'form-control')
          end

          describe 'self.#tag_helpers_opts' do
            it 'returns the custom settings' do
              expected = {
                tags_label_required_str: 'REQUIRED',
                tags_label_append_str: ':',
                tags_forms_default_class: 'form-control',
                tag_output_format_is_xhtml: true,

                orig_opts: {
                  tags_label_required_str: 'REQUIRED',
                  tags_label_append_str: ':',
                  tags_forms_default_class: 'form-control',
                  tag_output_format_is_xhtml: true
                }
              }
              _(@b.tag_helpers_opts).must_equal(expected)
            end
          end
          # /self.#tag_helpers_opts

          describe 'self.#tags_opts (plugin :tags)' do
            it 'returns :tag_output_format_is_xhtml => true' do
              _(@b.tags_opts[:tag_output_format_is_xhtml]).must_equal true
            end

            it 'returns :tags_label_required_str => "REQUIRED"' do
              _(@b.tags_opts[:tags_label_required_str]).must_equal 'REQUIRED'
            end

            it 'returns :tags_forms_default_class => "form-control"' do
              _(@b.tags_opts[:tags_forms_default_class]).must_equal 'form-control'
            end
          end
          # /self.#tags_opts (plugin :tags)
        end
        # /:opts - custom options

        describe 'loading plugin twice' do
          before do
            @c = Class.new(Roda)
            @c.plugin(:tag_helpers, tags_label_required_str: 'REQUIRED', tags_label_append_str: ':')
            @d = Class.new(@c)
            @d.plugin(:tag_helpers, tags_label_required_str: '<b>Required</b>')
          end

          describe 'self.#tag_helpers_opts' do
            it 'returns the last set options' do
              expected = {
                tags_label_required_str: '<b>Required</b>',
                tags_label_append_str: ':',
                tags_forms_default_class: '',
                orig_opts: {
                  tags_label_required_str: '<b>Required</b>',
                  tags_label_append_str: ':',
                  tags_forms_default_class: ''
                }
              }
              _(@d.tag_helpers_opts).must_equal(expected)
            end
          end
          # /self.#tag_helpers_opts
        end
        # /loading plugin twice
      end
      # /plugin :tag_helpers
    end
    # /RodaTagHelpers
  end
  # /RodaPlugins
end
# /Roda
# rubocop:enable Metrics/BlockLength
