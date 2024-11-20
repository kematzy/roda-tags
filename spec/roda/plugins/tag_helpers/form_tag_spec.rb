# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTagHelpers' do
      describe 'plugin :tag_helpers' do
        describe 'InstanceMethods' do
          describe '#form_tag' do
            describe 'basic rendering' do
              it 'renders minimal form with action' do
                html = tag_helpers_app("<% form_tag('/submit') %>")
                _(html).must_have_tag('form[@action="/submit"][@method=post]')
              end

              it 'handles empty attributes' do
                html = tag_helpers_app("<% form_tag('/submit', {}) %>")
                _(html).must_have_tag('form[@action="/submit"][@method=post]')
              end
            end
            # /basic rendering

            describe 'HTTP methods' do
              describe 'standard methods' do
                %w[get post].each do |method|
                  it "renders direct #{method.upcase} method" do
                    html = tag_helpers_app("<% form_tag('/submit', method: :#{method}) %>")
                    _(html).must_have_tag("form[@method=#{method}]")
                    _(html).wont_have_tag('input[@name="_method"]')
                  end
                end
              end

              describe 'faux methods' do
                %w[put patch delete].each do |method|
                  it "renders faux #{method.upcase} method" do
                    html = tag_helpers_app("<% form_tag('/submit', method: :#{method}) %>")
                    _(html).must_have_tag('form[@method=post]')
                    _(html).must_have_tag(
                      "input[@type=hidden][@name='_method'][@value='#{method.upcase}']"
                    )
                  end
                end
              end
            end
            # /HTTP methods

            describe 'attributes handling' do
              it 'supports custom id' do
                html = tag_helpers_app("<% form_tag('/submit', id: 'custom-form') %>")
                _(html).must_have_tag('form#custom-form')
              end

              it 'supports multiple classes' do
                html = tag_helpers_app("<% form_tag('/submit', class: 'form-inline important') %>")
                _(html).must_have_tag('form.form-inline.important')
              end

              it 'supports data attributes' do
                html = tag_helpers_app(
                  "<% form_tag('/submit', data: { remote: true, type: 'json' }) %>"
                )
                _(html).must_have_tag('form[@data-remote="true"][@data-type="json"]')
              end
            end
            # /attributes handling

            describe 'multipart forms' do
              it 'supports multipart true flag' do
                html = tag_helpers_app("<% form_tag('/submit', multipart: true) %>")
                _(html).must_have_tag('form[@enctype="multipart/form-data"]')
              end

              it 'supports explicit multipart value' do
                html = tag_helpers_app(
                  "<% form_tag('/submit', multipart: 'multipart/form-data') %>"
                )
                _(html).must_have_tag('form[@enctype="multipart/form-data"]')
              end

              it 'supports direct enctype attribute' do
                html = tag_helpers_app("<% form_tag('/submit', enctype: 'multipart/form-data') %>")
                _(html).must_have_tag('form[@enctype="multipart/form-data"]')
              end
            end
            # /multipart forms

            describe 'nested content' do
              it 'renders nested form elements' do
                template = <<~ERB
                  <% form_tag('/submit') do %>
                    <%= text_field_tag(:name) %>
                    <%= submit_tag %>
                  <% end %>
                ERB

                html = tag_helpers_app(template)
                _(html).must_have_tag('form > input[@type="text"][@name="name"]')
                _(html).must_have_tag('form > input[@type="submit"]')
              end

              it 'handles complex nested structures' do
                template = <<~ERB
                  <% form_tag('/submit', class: 'form') do %>
                    <div class="field">
                      <%= label_tag(:email) %>
                      <%= text_field_tag(:email) %>
                    </div>
                    <div class="actions">
                      <%= submit_tag('Send') %>
                    </div>
                  <% end %>
                ERB

                html = tag_helpers_app(template)
                _(html).must_have_tag('form.form')
                _(html).must_have_tag('form > div.field > label[@for="email"]')
                _(html).must_have_tag('form > div.field > input[@name="email"]')
                _(html).must_have_tag('form > div.actions > input[@value="Send"]')
              end
            end
            # /nested content

            describe 'security features' do
              it 'escapes HTML in attributes' do
                skip 'TODO: add suppport for value sanitation'
                # html = tag_helpers_app(
                #   %(<% form_tag('/submit', id: '<script>alert("xss")</script>') %>)
                # )
                # _(html).wont_include('<script>')
                # _(html).must_include('&lt;script&gt;')
              end
            end
            # /security features

            describe 'error handling' do
              it 'handles nil action' do
                html = tag_helpers_app('<% form_tag(nil) %>')
                _(html).must_have_tag('form[@method="post"]')
              end

              it 'handles invalid method' do
                html = tag_helpers_app("<% form_tag('/submit', method: :invalid) %>")
                _(html).must_have_tag('form[@method="post"]')
                _(html).must_have_tag('input[@name="_method"][@value="INVALID"]')
              end
            end
            # /error handling
          end
          # / #form_tag
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
