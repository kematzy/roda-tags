# frozen_string_literal: true

require_relative '../../../spec_helper'

# rubocop:disable Metrics/BlockLength
describe Roda do
  describe 'RodaPlugins' do
    describe 'RodaTags' do
      describe 'plugin :tags' do
        describe 'InstanceMethods' do
          describe '#tag' do
            describe 'multi line tags ' do
              Roda::RodaPlugins::RodaTags::MULTI_LINE_TAGS.each do |t|
                describe "like <#{t}>" do
                  it "should have a '\\n' after the opening tag and before the closing tag" do
                    _(tag_app("<%= tag(:#{t},'contents') %>"))
                      .must_equal "<#{t}>\ncontents\n</#{t}>\n"
                  end

                  it 'works without contents passed in' do
                    _(tag_app("<%= tag(:#{t},nil) %>")).must_equal "<#{t}>\n</#{t}>\n"
                  end

                  it 'allows a hash of attributes to be passed' do
                    _(tag_app("<%= tag(:#{t},'contents', id: 'tid', class: 'klass') %>"))
                      .must_match(/class="klass" id="tid"/)
                    # body.should have_tag("#{t}#tag-id.tag-class","\ncontents\n")
                  end

                  it "with ':newline => false' should NOT add '\\n' around the contents" do
                    _(tag_app("<%= tag(:#{t},'content', :id => 'tag-id', :newline => false) %>"))
                      .must_equal "<#{t} id=\"tag-id\">content</#{t}>\n"
                  end
                end
                # / like ##{t}
              end
              # / loop

              describe 'like <textarea>' do
                it "should NOT have a '\\n' after the opening tag and before the closing tag" do
                  _(tag_app("<%= tag(:textarea,'contents') %>"))
                    .must_equal "<textarea>contents</textarea>\n"
                end

                it 'should work without contents passed in' do
                  _(tag_app('<%= tag(:textarea,nil) %>')).must_equal "<textarea></textarea>\n"
                end

                it 'allows a hash of attributes to be passed' do
                  html = tag_app("<%= tag(:textarea,'contents', id: 'tag-id', class: 'klass') %>")

                  _(html).must_have_tag('textarea#tag-id.klass')
                end

                it "with ':newline => false' should NOT add '\\n' around the contents" do
                  _(tag_app("<%= tag(:textarea,'content', id: 'tag-id', newline: false) %>"))
                    .must_equal %(<textarea id="tag-id">content</textarea>\n)
                end
              end
              # / like #textarea
            end
            # / multi line tags

            describe 'self closing tags ' do
              Roda::RodaPlugins::RodaTags::SELF_CLOSING_TAGS.each do |t|
                describe "like <#{t}>" do
                  it "has a '\\n' after the opening tag and before the closing tag" do
                    _(tag_app("<%= tag(:#{t},'contents') %>")).must_equal "<#{t}>\n"
                  end

                  it "adds a '/' to close the tag if format is XHTML" do
                    _(tag_app("<%= tag(:#{t}) %>", {}, { tag_output_format_is_xhtml: true }))
                      .must_equal "<#{t} />\n"
                  end

                  it 'works without contents passed in' do
                    _(tag_app("<%= tag(:#{t},nil) %>")).must_equal "<#{t}>\n"
                  end

                  it 'ignores the contents passed in' do
                    _(tag_app("<%= tag(:#{t},'contents') %>")).must_equal "<#{t}>\n"
                  end

                  it 'allows a hash of attributes to be passed' do
                    _(tag_app("<%= tag(:#{t},'contents', id: 'tid', class: 'klass') %>"))
                      .must_match(/class="klass" id="tid"/)
                  end

                  it "with ':newline => false' should NOT add '\\n' around the contents" do
                    _(tag_app("<%= tag(:#{t},'content', :id => 'tag-id', :newline => false) %>"))
                      .must_equal "<#{t} id=\"tag-id\">"
                  end
                end
                # / like ##{t}
              end
              # / loop

              describe 'like <textarea>' do
                it "does NOT have a '\\n' after the opening tag and before the closing tag" do
                  _(tag_app("<%= tag(:textarea,'contents') %>"))
                    .must_equal "<textarea>contents</textarea>\n"
                end

                it 'works without contents passed in' do
                  _(tag_app('<%= tag(:textarea,nil) %>')).must_equal "<textarea></textarea>\n"
                end

                it 'allows a hash of attributes to be passed' do
                  assert_have_tag(
                    tag_app("<%= tag(:textarea,'contents', id: 'tag-id', class: 'tag-class') %>"),
                    'textarea#tag-id.tag-class'
                  )
                end

                it "with ':newline => false' should NOT add '\\n' around the contents" do
                  html = tag_app("<%= tag(:textarea,'content', id: 'tag-id', newline: false) %>")

                  _(html).must_equal %(<textarea id="tag-id">content</textarea>\n)
                end
              end
              # / like #textarea
            end
            # / multi line tags

            it 'returns the correct <br> tag' do
              _(tag_app('<%= tag(:br) %>')).must_equal "<br>\n"

              html = tag_app('<%= tag(:br) %>', {}, { tag_output_format_is_xhtml: true }).strip

              _(html).must_equal '<br />'
            end

            it 'returns the correct <div> tag' do
              _(tag_app('<%= tag(:div) %>')).must_equal "<div>\n</div>\n"
            end

            it 'returns the correct <section> tag' do
              _(tag_app('<%= tag(:section) %>')).must_equal "<section>\n</section>\n"
            end

            it 'returns the correct <input> tag' do
              html = tag_app(
                '<%= tag(:input, type: :text, id: :idval, class: :klass) %>'
              )

              _(html).must_equal %(<input class="klass" id="idval" type="text">\n)
            end

            it 'handles data hashes correctly' do
              html = tag_app(
                "<%= tag(:div, id: 'ID', class: 'klass', data: { c: 'C', b: 'B', a: 'A' }) %>"
              )

              _(html).must_equal(
                %(<div class="klass" data-a="A" data-b="B" data-c="C" id="ID">\n</div>\n)
              )
            end

            it 'handles block output correctly' do
              str = <<~ERB
                <% tag(:section, id: :intro, class: :row) do %>
                  <% tag(:div, class: 'col-md-12') do %>
                    <h1>Blocks Works too</h1>
                  <% end %>
                <% end %>
              ERB

              html = <<~HTML
                <section class="row" id="intro">
                <div class="col-md-12">
                    <h1>Blocks Works too</h1>
                </div>
                </section>
              HTML
              _(tag_app(str)).must_equal(html)
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
