require_relative '../spec_helper'

describe Roda do
  
  describe 'RodaPlugins' do
    
    describe 'RodaTagHelpers => :tag_helpers' do
      
      describe ':tag_helpers opts' do
    
        describe 'defaults' do
          before do
            @a = Class.new(Roda)
            @a.plugin(:tag_helpers)
          end

          it 'should have the default settings' do
            expected = {
              tags_label_required_str:      '<span>*</span>',
              tags_label_append_str:        ':',
              tags_forms_default_class:     '',
              orig_opts: {
                tags_label_required_str:      '<span>*</span>',
                tags_label_append_str:        ':',
                tags_forms_default_class:     '',
              }
            }
            @a.tag_helpers_opts.must_equal(expected)
          end
      
        end
    
        describe 'custom settings' do
          before do
            @b = Class.new(Roda)
            @b.plugin(:tag_helpers, 
                       tag_output_format_is_xhtml:  true, 
                       tags_label_required_str:     'REQUIRED',
                       tags_forms_default_class:    'form-control',
                      )
          end
      
          it 'should have the custom settings' do
            expected = {
              tags_label_required_str:      'REQUIRED',
              tags_label_append_str:        ':',
              tags_forms_default_class:     'form-control',
              tag_output_format_is_xhtml:   true,
              
              orig_opts: {
                tags_label_required_str:      'REQUIRED',
                tags_label_append_str:        ':',
                tags_forms_default_class:     'form-control',
                tag_output_format_is_xhtml:   true,
              }
            }
            @b.tag_helpers_opts.must_equal(expected)
          end
      
      
          it 'should set :tag_output_format_is_xhtml: to true' do
            @b.tags_opts[:tag_output_format_is_xhtml].must_equal true
          end
      
          it 'should set :tags_label_required_str to "REQUIRED" the custom settings' do
            @b.tag_helpers_opts[:tags_label_required_str].must_equal "REQUIRED"
          end
      
          it 'should set :tags_forms_default_class to "form-control" the custom settings' do
            @b.tag_helpers_opts[:tags_forms_default_class].must_equal "form-control"
          end
      
        end
        
        describe 'double loading of plugin' do
          before do
            @c = Class.new(Roda)
            @c.plugin(:tag_helpers,  tags_label_required_str: 'REQUIRED', tags_label_append_str: ':')
            @d = Class.new(@c)
            @d.plugin(:tag_helpers, tags_label_required_str: '<b>Required</b>')
          end
          
          it 'should have the custom settings' do
            @c.tags_opts[:orig_opts].must_equal({
              tag_output_format_is_xhtml:   false, 
              tag_add_newlines_after_tags:  true, 
              tags_label_required_str:      "REQUIRED", 
              tags_label_append_str:        ":"
            })
            @d.tags_opts[:orig_opts].must_equal({
              tag_output_format_is_xhtml:   false, 
              tag_add_newlines_after_tags:  true, 
              tags_label_required_str:      "<b>Required</b>",
              tags_label_append_str:        ":"
            })
            
          end
          
        end
        

      end # / opts
      
      
      describe 'Instance Methods' do
        
        
        describe "#form_tag" do 
        
          it "should return a basic form tag" do 
            html = tag_helpers_app("<% form_tag('/register', id: 'register-form' ) %>")
            html.must_have_tag('form#register-form[@action="/register"][@method=post]')
            html.wont_have_tag('input[@type=hidden]')
          end
        
          %w(put delete).each do |m| 
            
            it "should return a form tag with a faux method hidden tag when given a method => :#{m} " do 
              html = tag_helpers_app("<% form_tag('/register', method: :#{m}, id: 'register-form' ) %>")
              html.must_have_tag("form#register-form[@action='/register'][@method=post]")
              html.must_have_tag('form#register-form')
            
              html.must_have_tag(%Q{input[@type=hidden][@name="_method"][@value="#{m.upcase}"]})
            end
            
          end
        
          %w(get post).each do |m|
            
            it "should NOT include a fauxmethod tag when given a method => :#{m} " do 
              html = tag_helpers_app("<% form_tag('/register', method: :#{m}, id: 'register-form' ) %>")
              html.must_have_tag("form#register-form[@action='/register'][@method=#{m}]")
              html.wont_have_tag('input[@type=hidden]')
            end
            
          end
        
          [ 
            ['multipart', true], 
            ['multipart', '"multipart/form-data"'], 
            ['enctype', '"multipart/form-data"'] 
          ].each do |k, v|
          
            it "renders the form with :#{k} => #{v}" do 
              html = tag_helpers_app("<% form_tag('/register', #{k}: #{v} ) %>")
              html.must_have_tag('form[@action="/register"][@method=post][@enctype="multipart/form-data"]')
            end
          
          end
        
          it "should return the form tag with the block" do 
            str = <<-ERB
<% form_tag('/register', id: 'register-form' ) do %>
  <p>
    <%= label_tag :name %><br>
    <%= text_field_tag :name %>
  </p>
  <p><%= text_field_tag :biography %></p>
  <p><%= text_field_tag :lead, label: 'Lead Role ?' %></p>
<% end %>
ERB
            html = tag_helpers_app(str)
            # html.must_equal 'd'
            html.must_have_tag('form#register-form[@action="/register"][@method=post]')
            html.must_have_tag('form > p > label[@for=name]', 'Name:')
            html.must_have_tag('form > p > input[@name=name]')
          end
        
        end #/ #form_tag
        
        
        
        describe "#label_tag" do 
        
          it "should return a basic label" do
            tag_helpers_app('<%= label_tag(:name) %>')
              .must_equal "<label for=\"name\">Name:</label>\n"
            tag_helpers_app('<%= label_tag(:name) %>').must_have_tag('label[@for=name]', 'Name:' )
          end
        
          it "should allow overriding of label text" do
            tag_helpers_app("<%= label_tag(:name, label: 'Custom label') %>")
              .must_have_tag('label[@for=name]','Custom label:')
          end

          it "should handle nil values for the label text" do
            tag_helpers_app("<%= label_tag(:name, label: nil) %>")
              .must_have_tag('label[@for=name]','Name:')
          end

          it "should remove label text when :label => false " do
            tag_helpers_app("<%= label_tag(:name, label: false) %>")
              .must_have_tag('label[@for=name]','')
          end

          it "should add required * when provided" do
            tag_helpers_app('<%= label_tag(:name, required: true) %>')
              .must_have_tag('label[@for=name]','Name: <span>*</span>')
          end
        
          it "should add class when provided" do
            tag_helpers_app('<%= label_tag(:name, class: "custom") %>')
              .must_have_tag('label[@for=name][@class="custom"]','Name:')
          end
          
          it 'should support passed blocks' do
            str = <<-ERB
<% label_tag :name do %>
  <%= check_box_tag 'name' %>
<% end %>
ERB
           html = tag_helpers_app(str)
           # html.must_equal ''
           html.must_have_tag('label[@for=name] > input[@type=checkbox][@class=checkbox][@id=name][@value="1"]')
          end
        
        end #/ #label_tag
        
        describe "#hidden_field_tag" do 
        
          it "should render a hidden tag with custom value and id attributes" do 
            html = tag_helpers_app("<%= hidden_field_tag(:snippet_name, :value =>'myvalue') %>")
            html.must_have_tag('input[@type=hidden]')
            html.must_have_tag('input[@type=hidden][id=snippet_name]')
            html.must_have_tag('input[@type=hidden][name=snippet_name]')
            html.must_have_tag('input[@type=hidden][value=myvalue]')
          end
        
          it "should render a hidden tag without value but with custom id attribute" do 
            tag_helpers_app("<%= hidden_field_tag(:snippet_name, :id => 'some-id') %>")
              .must_have_tag('input[@type=hidden][@id=some-id][@name=snippet_name][@value=""]')
          end
        
          it "should render an empty hidden tag with default attributes" do 
            tag_helpers_app("<%= hidden_field_tag(:snippet_name) %>")
              .must_have_tag('input[@type=hidden][@id=snippet_name][@name=snippet_name][@value=""]')
          end
        
          it "should remove the :id attribute when ':id => false'" do 
            tag_helpers_app("<%= hidden_field_tag(:snippet, :id => false ) %>")
              .must_have_tag('input[@type=hidden][@name=snippet][@value=""]')
          end
        
          it "should render an empty hidden tag when only one attribute is passed" do 
            tag_helpers_app("<%= hidden_field_tag(:snippet ) %>")
              .must_have_tag('input[@type=hidden][@name=snippet][@id=snippet][@value=""]')
          end
        
        end #/ #hidden_field_tag
      
        describe "#text_field_tag" do

          it "should render a basic textfield tag when only one attribute is passed" do
            html = tag_helpers_app("<%= text_field_tag(:snippet_name) %>")
            html.must_equal(%Q{<input class="text" id="snippet_name" name="snippet_name" type="text">\n})
          end
          
          it "should render a textfield tag with a value" do
            html = tag_helpers_app("<%= text_field_tag(:snippet_name, value: 'some-value') %>")
            html.must_equal(%Q{<input class="text" id="snippet_name" name="snippet_name" type="text" value="some-value">\n})
            html.must_have_tag('input[@type=text][@class=text][@value="some-value"]')
            # html.must_have_tag('input[@type=text][@id=snippet_name][@name=snippet_name][@value="some-value"]')
          end

          it "should render a textfield tag with a custom id attribute" do
            html = tag_helpers_app("<%= text_field_tag(:snippet_name, id: 'some-id') %>")
            html.must_have_tag('input[@id=some-id]')
            html.must_have_tag('input[@type=text][@class=text][@name=snippet_name]')
          end

          it "should remove the :id attribute when 'id: false'" do
            html = tag_helpers_app("<%= text_field_tag(:snippet_name, id: false) %>")
            html.must_equal(%Q{<input class="text" name="snippet_name" type="text">\n})
            html.wont_have_tag('input[@type=text][@id]')
          end

          it "should render a textfield tag with a merged class attribute" do
            tag_helpers_app("<%= text_field_tag(:snippet_name, :class => :big ) %>")
              .must_have_tag('input[@type=text][@class="big text"][@id=snippet_name]') 
          end

          it "should render a textfield with a :title attribute when :ui_hint / :title is passed" do
            html = tag_helpers_app("<%= text_field_tag(:name, ui_hint: 'UI-HINT') %>")
            html.must_have_tag('input[@type=text][@title="UI-HINT"]')
            html.must_have_tag('input[@type=text][@id=name][@name=name]')

            html = tag_helpers_app("<%= text_field_tag(:name, title: 'UI-HINT') %>")
            html.must_have_tag('input[@type=text][@title="UI-HINT"]')
            html.must_have_tag('input[@type=text][@id=name][@name=name]')
          end
          
          it "should render a textfield with a :size & :maxlength attributes when passed" do
            html = tag_helpers_app(%Q{<%= text_field_tag(:ip, value: '0.0.0.0', maxlength: 15, size: '20') %>})
            html.must_have_tag('input.text[@type=text][@maxlength="15"][@size="20"][@value="0.0.0.0"]')
            html.must_have_tag('input.text[@type=text][@id=ip][@name=ip]')
          end

          it "should render a textfield tag with content :disabled => true" do
            html = tag_helpers_app("<%= text_field_tag(:snippet_name, value: 'some-value', disabled: true) %>")
            html.must_have_tag('input[@type=text][@disabled=disabled][@value="some-value"]')
            html.must_have_tag('input[@type=text][@id=snippet_name][@name=snippet_name]')
          end

          it "should render a readonly textfield tag when given :readonly => true" do
            html = tag_helpers_app("<%= text_field_tag(:snippet_name, value: 'some-value', readonly: true) %>")
            html.must_have_tag('input[@type=text][@readonly=readonly]')
            html.must_have_tag('input[@type=text][@id=snippet_name][@name=snippet_name][@value="some-value"]')
          end

        end #/ #text_field_tag
      
        describe "#password_field_tag" do

          it "should render a basic password field tag when only one attribute is passed" do
            html = tag_helpers_app("<%= password_field_tag(:snippet_name) %>")
            html.must_equal %Q{<input class="text" id="snippet_name" name="snippet_name" type="password">\n}
            html.must_have_tag('input[@type=password]')
            html.must_have_tag('input[@name=snippet_name]')
            html.must_have_tag('input[@id=snippet_name]')
            html.wont_have_tag('input[@value]')
          end

          it "should render a password field tag with a value" do
            html = tag_helpers_app("<%= password_field_tag(:snippet_name, value: 'some-value') %>")
            html.must_have_tag('input[@value="some-value"]')
            html.must_have_tag('input.text[@type=password][@class=text][@id=snippet_name][@name=snippet_name]')
          end

          it "should render a password field tag with a custom id attribute" do
            html = tag_helpers_app("<%= password_field_tag(:snippet_name, id: 'some-id') %>")
            html.must_have_tag('input[@id="some-id"]')
            html.must_have_tag('input.text[@type=password][@class=text][@id="some-id"][@name=snippet_name]')
          end

          it "should render a password field tag with a merged class attribute" do
            html = tag_helpers_app("<%= password_field_tag(:snippet_name, class: :big ) %>")
            html.must_have_tag('input[@class="big text"]')
            html.must_have_tag('input.text[@type=password][@class="big text"][@id=snippet_name][@name=snippet_name]')
          end

          it "should render a password field with a :title attribute when :ui_hint is passed" do
            html = tag_helpers_app("<%= password_field_tag(:name, ui_hint: 'UI-HINT') %>")
            # html.must_equal('<input class="text" id="name" name="name" title="UI-HINT" type="password">')
            html.must_have_tag('input[@title="UI-HINT"]')
            html.must_have_tag('input.text[@type=password][@class=text][@id=name][@name=name]')
          end

          it "should render a textfield with a :size & :maxlength attributes when passed" do
            html = tag_helpers_app(%Q{<%= password_field_tag(:snippet_name, maxlength: 15, size: '20') %>})
            html.must_have_tag('input[@maxlength="15"][@size="20"]')
            html.must_have_tag('input.text[@type=password][@class=text][@id=snippet_name][@name=snippet_name]')
          end

          it "should render a textfield tag with content :disabled => true" do
            html = tag_helpers_app("<%= password_field_tag(:snippet_name, disabled: true) %>")
            html.must_have_tag('input[@disabled=disabled]')
            html.must_have_tag('input.text[@type=password][@class=text][@id=snippet_name][@name=snippet_name]')
          end

        end #/ #password_field_tag
        
        describe "#file_field_tag" do

          it "should render a basic file field tag when only one attribute is passed" do
            html = tag_helpers_app("<%= file_field_tag(:attachment) %>")
            html.must_equal %Q{<input class="file" id="attachment" name="attachment" type="file">\n}
            html.must_have_tag('input[@type=file]')
            html.must_have_tag('input[@class=file]')
            html.must_have_tag('input[@id=attachment]')
            html.must_have_tag('input[@name=attachment]')
            html.wont_have_tag('input[@value]')
          end

          it "should render a file field tag without the value attribute when passed" do
            html = tag_helpers_app("<%= file_field_tag(:photo, value: 'some-value') %>")
            html.must_equal(%Q{<input class="file" id="photo" name="photo" type="file">\n})
            html.wont_have_tag('input[@value]')
            html.must_have_tag('input[@type=file][@class=file][@id=photo][@name=photo]')
          end

          it "should render a file field tag with a custom id attribute" do
            html = tag_helpers_app("<%= file_field_tag(:photo, id: 'some-id') %>")
            html.must_have_tag('input[@id="some-id"]')
            html.must_have_tag('input[@type=file][@class=file][@name=photo]')
          end

          it "should render a file field tag with a merged class attribute" do
            html = tag_helpers_app("<%= file_field_tag(:photo, class: :big ) %>")
            html.must_have_tag('input[@class="big file"]')
            html.must_have_tag('input[@type=file][@id=photo][@name=photo]')
          end

          it "should render a file field with a :title attribute when :ui_hint is passed" do
            html = tag_helpers_app("<%= file_field_tag(:photo, ui_hint: 'UI-HINT') %>")
            html.must_have_tag('input[@title="UI-HINT"]')
            html.must_have_tag('input[@type=file][@class=file][@id=photo][@name=photo]')
          end

          it "should render a file field with :disabled => true" do
            html = tag_helpers_app("<%= file_field_tag(:photo, disabled: true) %>")
            html.must_have_tag('input[@disabled=disabled]')
            html.must_have_tag('input[@type=file][@class=file][@id=photo][@name=photo]')
          end

          it "should render a file field with an :accept attribute when :accept is passed" do
            html = tag_helpers_app("<%= file_field_tag(:photo, accept: 'image/png,image/gif,image/jpeg' ) %>")
            html.must_have_tag('input[@accept="image/png,image/gif,image/jpeg"]')
            html.must_have_tag('input[@type=file][@class=file][@id=photo][@name=photo]')
          end
        
        end #/ #file_field_tag

        describe "#textarea_tag" do

          it "should render a basic textarea tag when only one attribute is passed" do
            html = tag_helpers_app("<%= textarea_tag(:post) %>")
            html.must_equal %Q{<textarea id="post" name="post"></textarea>\n}
            html.must_have_tag('textarea[@id=post]')
            html.must_have_tag('textarea[@name=post]')
          end

          it "should render a textarea tag with a value" do
            html = tag_helpers_app("<%= textarea_tag(:post, value: 'some-value') %>")
            html.must_have_tag('textarea#post',"some-value")
            html.wont_have_tag('textarea#post[@value=some-value]')
          end

          it "should render a textarea tag with a custom id attribute" do
            html = tag_helpers_app("<%= textarea_tag(:body, id: 'some-id') %>")
            html.must_have_tag('textarea[@id="some-id"]','')
            html.must_have_tag('textarea[@name=body]')
          end

          it "should render a textarea tag with a class attribute" do
            html = tag_helpers_app("<%= textarea_tag(:snippet, class: :big ) %>")
            html.must_have_tag('textarea[@class=big]','')
            html.must_have_tag('textarea[@id=snippet][@name=snippet]')
          end

          it "should render a textarea with a :title attribute when :ui_hint is passed" do
            html = tag_helpers_app("<%= textarea_tag(:name, ui_hint: 'UI-HINT') %>")
            html.must_have_tag('textarea[@title="UI-HINT"]','')
            html.must_have_tag('textarea[@id=name][@name=name]')
          end

          it "should render a textarea with a :cols & :rows attributes when passed" do
            html = tag_helpers_app("<%= textarea_tag(:body, rows: 10, cols: 25) %>")
            html.must_have_tag('textarea[@rows="10"][@cols="25"]','')
            html.must_have_tag('textarea[@id=body][@name=body]')
            html.must_equal %Q{<textarea cols="25" id="body" name="body" rows="10"></textarea>\n}
          end

          it "should render a textarea with a :cols & :rows attributes when passed a :size attribute" do
            html = tag_helpers_app("<%= textarea_tag(:body, size: '15x20') %>")
            html.must_have_tag('textarea[@cols="15"][@rows="20"]','')
            html.must_have_tag('textarea[@id=body][@name=body]')
          end

          it "should render a textarea tag with content :disabled => true" do
            html = tag_helpers_app('<%= textarea_tag(:description, value: "Description goes here.", disabled: true) %>')
            html.must_have_tag('textarea[@disabled=disabled]', 'Description goes here.')
            html.must_have_tag('textarea[@id=description][@name=description]')
          end

          it "should render a textarea tag with content :readonly => true" do
            html = tag_helpers_app('<%= textarea_tag(:description, value: "Description goes here.", readonly: true) %>')
            html.must_have_tag('textarea[@readonly=readonly]', 'Description goes here.')
            html.must_have_tag('textarea[@id=description][@name=description]')
          end

        end #/ #textarea_tag

        describe "#field_set_tag" do

          it "should render a basic fieldset without a block" do
            html = tag_helpers_app("<% field_set_tag(:actor) %>")
            html.must_have_tag('fieldset#fieldset-actor')
            html.must_have_tag('fieldset[@id=fieldset-actor]')
          end

          it "should render a fieldset with a legend and a block" do
            str = <<-ERB
<% field_set_tag 'User Details' do %>
  <p><%= text_field_tag 'name' %></p>
<% end %>
ERB
           html = tag_helpers_app(str)
           html.must_have_tag('fieldset#fieldset-user-details > legend', 'User Details')
           html.must_have_tag('fieldset#fieldset-user-details > p > input#name[@type=text][@class=text][@id=name][@name=name]')
           # html.must_equal %Q{<fieldset id="fieldset-user-details">\n  <legend>User Details</legend>\n   <p><input class="text" id="name" name="name" type="text">\n</p></fieldset>\n}
          end

          it "should render a fieldset with class and legend" do
            html = tag_helpers_app(%Q{<% field_set_tag(:actor, legend: 'User Details', class: "legend-class") %>})
            html.must_have_tag('fieldset#fieldset-actor.legend-class > legend', 'User Details')
            html.must_have_tag('fieldset[@class=legend-class][@id=fieldset-actor] > legend', 'User Details')
          end

          it "should render a fieldset without :id when :id => false" do
            html = tag_helpers_app(%Q{<% field_set_tag(:actor, legend: 'User Details', id: false) %>})
            html.must_have_tag('fieldset > legend', 'User Details')

            html = tag_helpers_app(%Q{<% field_set_tag('User Details', id: false) %>})
            html.must_have_tag('fieldset > legend', 'User Details')
            html.wont_have_tag('fieldset[@id]')
          end

          it "should render a fieldset with :id attribute as 'fieldset' when passed nil as first args" do
            html = tag_helpers_app(%Q{<% field_set_tag(nil, :legend => 'User Details', :class => 'big') %>})
            html.must_have_tag('fieldset.big > legend', 'User Details')
          end

          it "should render a fieldset with a block" do
str = <<-ERB
<% field_set_tag(:actor, :legend => 'User Details', :class => "legend-class") do %>
  <p><%= text_field_tag :name %></p>
<% end %>
ERB
            html = tag_helpers_app(str)
            html.must_have_tag('fieldset#fieldset-actor.legend-class > legend', 'User Details')
            html.must_have_tag('fieldset > p > input#name.text[@name=name]')
          end

        end #/ #field_set_tag
        
        describe "#legend_tag" do

          it "should return a simple legend tag" do
            tag_helpers_app("<%= legend_tag('User Details') %>")
              .must_have_tag('legend','User Details')
          end

          it "should return a legend tag with id attribute" do
            tag_helpers_app("<%= legend_tag('User Details', id: 'some-id') %>")
              .must_have_tag('legend#some-id', 'User Details')
          end

          it "should return a legend tag with class attribute" do
            tag_helpers_app("<%= legend_tag('User Details', class: 'some-class') %>")
              .must_have_tag('legend[@class=some-class]','User Details')
          end

          it "should handle a nil value passed" do
            tag_helpers_app("<%= legend_tag(nil) %>").must_have_tag('legend','')
          end

        end #/ #legend_tag
        
        describe "#check_box_tag" do

          it "should render a basic check_box tag when only one attribute is passed" do
            html = tag_helpers_app("<%= check_box_tag :accept %>")
            html.must_have_tag('input.checkbox[@type=checkbox]')
            html.must_have_tag('input[@type=checkbox][@class=checkbox][@value="1"]')
            html.must_have_tag('input[@type=checkbox][@id=accept][@name=accept]')
          end

          it "should render a basic check_box tag with a value" do
            html = tag_helpers_app("<%= check_box_tag :rock, value: 'rock music' %>")
            html.must_have_tag('input.checkbox[@type=checkbox][@value="rock music"]')
            html.must_have_tag('input.checkbox[@id=rock][@name=rock]')
          end

          it "should render a basic check_box tag with a custom id attribute" do
            html = tag_helpers_app("<%= check_box_tag :rock, id: 'some-id' %>")
            html.must_have_tag('input[@type=checkbox][@id="some-id"]')
            html.must_have_tag('input.checkbox[@name=rock][@value="1"]')
          end

          it "should render a basic check_box tag with a merged class attribute" do
            html = tag_helpers_app("<%= check_box_tag :rock, class: 'small' %>")
            html.must_have_tag('input[@type=checkbox][@class="checkbox small"]')
            html.must_have_tag('input[@type=checkbox][@id=rock][@name=rock][@value="1"]')
          end

          it "should render a basic check_box tag a :title attribute when :ui_hint is passed" do
            html = tag_helpers_app("<%= check_box_tag :rock, ui_hint: 'UI-HINT' %>")
            html.must_have_tag('input.checkbox[@type=checkbox][@title="UI-HINT"]')
            html.must_have_tag('input.checkbox[@type=checkbox][@name=rock][@value="1"]')
          end

          it "should render a basic check_box tag with :checked true" do
            html = tag_helpers_app("<%= check_box_tag :rock, checked: true %>")
            html.must_have_tag('input.checkbox[@type=checkbox][@checked=checked]')
            html.must_have_tag('input[@type=checkbox][@id=rock][@name=rock][@value="1"]')
          end

          it "should render a basic check_box tag with :disabled true" do
            html = tag_helpers_app("<%= check_box_tag :rock, disabled: true %>")
            html.must_have_tag('input.checkbox[@type=checkbox][@disabled=disabled]')
            html.must_have_tag('input[@type=checkbox][@id=rock][@name=rock][@value="1"]')
          end

        end #/ #check_box_tag

        describe "#radio_button_tag" do

          it "should render a basic radio_button tag " do
            html = tag_helpers_app("<%= radio_button_tag :accept %>")
            html.must_have_tag('input[@type=radio][@id=accept_1][@name=accept][@value="1"]')
          end

          it "should render tag with a value" do
            html = tag_helpers_app("<%= radio_button_tag :rock, value: 'rock music' %>")
            html.must_have_tag('input[@type=radio][@id="rock_rock-music"][@name=rock][@value="rock music"]')
          end

          it "should render tag with a custom id attribute" do
            html = tag_helpers_app("<%= radio_button_tag :rock, id: 'some-id' %>")
            html.must_have_tag('input.radio[@type=radio][@id="some-id_1"][@name=rock][@value="1"]')
          end

          it "should render tag with a merged class attribute" do
            tag_helpers_app("<%= radio_button_tag :rock, class: 'small' %>")
              .must_have_tag('input[@type=radio][@class="radio small"][@id="rock_1"][@value="1"]')
          end

          it "should render tag a :title attribute when :ui_hint is passed" do
            tag_helpers_app("<%= radio_button_tag :rock, ui_hint: 'UI-HINT' %>")
              .must_have_tag('input.radio[@type=radio][@title="UI-HINT"][@id=rock_1][@name=rock]')
          end

          it "should render tag with :checked true" do
            html =tag_helpers_app("<%= radio_button_tag :rock, :checked => true %>")
            html.must_have_tag('input.radio[@type=radio][@checked=checked]')
            html.must_have_tag('input.radio[@type=radio][@id=rock_1][@name=rock]')
          end

          it "should render tag with :disabled true" do
            html = tag_helpers_app("<%= radio_button_tag :rock, disabled: true %>")
            html.must_have_tag('input.radio[@type=radio][@disabled=disabled]')
            html.must_have_tag('input.radio[@type=radio][@id=rock_1][@name=rock]')
          end

        end #/ #radio_button_tag
        
        describe "#submit_tag" do

          it "should return a basic submit tag" do
            html = tag_helpers_app("<%= submit_tag %>")
            html.must_equal(%Q{<input name="submit" type="submit" value="Save Form">\n})
            html.must_have_tag('input[@type=submit][@name=submit][@value="Save Form"]')
          end

          it "should return a basic submit tag with custom value" do
            tag_helpers_app("<%= submit_tag('Custom Value') %>")
              .must_have_tag('input[@type=submit][@name=submit][@value="Custom Value"]')
          end

          it "should return a basic submit tag with empty value when given a nil value" do
            html = tag_helpers_app("<%= submit_tag(nil) %>")
            html.must_have_tag('input[@type=submit][@name=submit][@value=""]')
            # html.wont_have_tag('input[@type=submit][@value]')
          end

          it "should return a basic submit tag with a custom class attribute" do
            html = tag_helpers_app("<%= submit_tag('Custom Value', class: 'some-class' ) %>")
            html.must_have_tag('input[@type=submit][@class="some-class"][@value="Custom Value"]')
            html.must_have_tag('input[@type=submit][@name=submit]')
          end

          it "should return a basic submit tag with :ui_hint => ..." do
            html = tag_helpers_app("<%= submit_tag(ui_hint: 'UI-HINT' ) %>")
            html.must_have_tag('input[@type=submit][@title="UI-HINT"]')
            html.must_have_tag('input[@type=submit][@name=submit][@value="Save Form"]')
          end

          it "should return a basic submit tag with disabled: true" do
            html = tag_helpers_app("<%= submit_tag(disabled: true ) %>")
            html.must_have_tag('input[@type=submit][@disabled=disabled][@name=submit][@value="Save Form"]')
          end

        end #/ #submit_tag

        describe "#reset_tag" do

          it "should return a basic reset tag" do
            html = tag_helpers_app("<%= reset_tag %>")
            html.must_equal(%Q{<input name="reset" type="reset" value="Reset Form">\n})
            html.must_have_tag('input[@type=reset][@name=reset][@value="Reset Form"]')
          end

          it "should return tag with custom value" do
            tag_helpers_app("<%= reset_tag('Custom Value') %>")
              .must_have_tag('input[@type=reset][@name=reset][@value="Custom Value"]')
          end

          it "should return tag with empty value when given a nil value" do
            tag_helpers_app("<%= reset_tag(nil) %>")
              .must_have_tag('input[@type=reset][@name=reset][@value=""]')
          end

          it "should return tag with a custom class attribute" do
            tag_helpers_app("<%= reset_tag(class: 'some-class' ) %>")
              .must_have_tag('input[@type=reset][@class="some-class"][@name=reset][@value="Reset Form"]')
          end

          it "should return tag with :ui_hint => ..." do
            tag_helpers_app("<%= reset_tag(ui_hint: 'UI-HINT' ) %>")
              .must_have_tag('input[@type=reset][@title="UI-HINT"][@name=reset][@value="Reset Form"]')
          end

          it "should return tag with :disabled => true" do
            tag_helpers_app("<%= reset_tag('Custom Value', disabled: true ) %>")
              .must_have_tag('input[@type=reset][@disabled=disabled][@value="Custom Value"]')
          end

        end #/ #reset_tag
        
        describe "#image_submit_tag" do

          it "should return a simple tag" do
            tag_helpers_app('<%= image_submit_tag("/images/login.png") %>')
              .must_have_tag('input[@type=image][@src="/images/login.png"]')
          end

          it "should return a tag with custom class" do
            tag_helpers_app('<%= image_submit_tag("/images/search.png", class: "search-button") %>')
              .must_have_tag('input.search-button[@type=image][@src="/images/search.png"]')
          end

          it "should return a disabled tag with :disabled => true" do
            tag_helpers_app('<%= image_submit_tag("/images/purchase.png", disabled: true) %>')
              .must_have_tag('input[@type=image][@disabled=disabled][@src="/images/purchase.png"]')
          end

        end #/ #image_submit_tag
        

        describe "#select_tag" do

          it "should render a basic select tag from a Hash" do
            html = tag_helpers_app("<%= select_tag(:letters, {a: 'A', b: 'B'}) %>")
            # html.must_equal ""
            html.must_have_tag('select#letters[@name=letters] > option[@value=a]','A')
            html.must_have_tag('select#letters[@name=letters] > option[@value=b]','B')
          end

          it "should render tag from an Array" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']]) %>")
            html.must_have_tag('select#letters[@name=letters] > option[@value=a]', 'A')
            html.must_have_tag('select#letters[@name=letters] > option[@value=b]', 'B')
          end

          it "should render tag with the selected value" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']], selected: :a) %>")
            html.must_have_tag('select#letters[@name=letters] > option[@value=a][@selected=selected]', 'A')
            html.must_have_tag('select#letters[@name=letters] > option[@value=b]', 'B')
          end

          it "should render tag with multiple selected values" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']], selected: [:a,'b'] ) %>")
            html.must_have_tag('select#letters[@name="letters[]"][@multiple=multiple]')
            html.must_have_tag('select#letters > option[@value=a][@selected=selected]', 'A')
            html.must_have_tag('select#letters > option[@value=b][@selected=selected]', 'B')
          end

          it "should render tag with :multiple => true" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']], multiple: true) %>")
            html.must_have_tag('select#letters[@name="letters[]"][@multiple=multiple]')
            html.must_have_tag('select#letters > option[@value=a]', 'A')
            html.must_have_tag('select#letters > option[@value=b]', 'B')
          end

          it "should render tag with :disabled => true" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']], disabled: true ) %>")
            html.must_have_tag('select#letters[@name=letters][@disabled=disabled]')
            html.must_have_tag('select#letters > option[@value=a]', 'A')
            html.must_have_tag('select#letters > option[@value=b]', 'B')
          end

          it "should render tag with a custom id" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']], id: 'my-letters') %>")
            html.must_have_tag('select#my-letters[@name=letters]')
            html.must_have_tag('select#my-letters > option[@value=a]', 'A')
            html.must_have_tag('select#my-letters > option[@value=b]', 'B')
          end

          it "should render tag with a custom class" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']], class: 'funky-select') %>")
            html.must_have_tag('select#letters[@name=letters][@class="funky-select"]')
            html.must_have_tag('select#letters > option[@value=a]', 'A')
            html.must_have_tag('select#letters > option[@value=b]', 'B')
          end

          it "should render tag with prompt => true" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']], prompt: true ) %>")
            html.must_have_tag('select#letters[@name=letters]')
            html.must_have_tag('select#letters > option[@value=""][@selected=selected]', '- Select -')
            html.must_have_tag('select#letters > option[@value=a]', 'A')
            html.must_have_tag('select#letters > option[@value=b]', 'B')
          end

          it "should render tag with a custom prompt" do
            html = tag_helpers_app("<%= select_tag(:letters, [[:a, 'A'], [:b, 'B']], prompt: 'My Favourite Letters', selected: 'a') %>")
            html.must_have_tag('select#letters[@name=letters]')
            html.must_have_tag('select#letters > option[@value=""]', 'My Favourite Letters')
            html.must_have_tag('select#letters > option[@value=a][@selected=selected]', 'A')
            html.must_have_tag('select#letters > option[@value=b]', 'B')
          end

        end #/ #select_tag

        describe "#select_option" do

          it "should render a basic select option tag" do
            tag_helpers_app("<%= select_option('a', 'Letter A') %>")
              .must_have_tag('option[@value=a]', 'Letter A')
          end

          it "should handle a missing key value" do
            tag_helpers_app("<%= select_option('on', nil) %>")
              .must_have_tag('option[@value=on]', 'On')
          end

          it "should render tag with :selected => true" do
            tag_helpers_app("<%= select_option('a', 'Letter A', selected: true) %>")
              .must_have_tag('option[@value=a][@selected=selected]', 'Letter A')
          end

          it "should render tag without selected when given :selected => false" do
            html = tag_helpers_app("<%= select_option('a', 'Letter A', selected: false) %>")
            html.must_have_tag('option[@value=a]', 'Letter A')
            html.wont_have_tag('option[@selected=selected]')
          end

        end #/ #select_option

        
        
        
        describe 'private' do          
          
          describe '#html_safe_id' do
            
            it "should return a safe id from 'snippet_name'" do
              tag_helpers_app('<%= self.send(:html_safe_id, "snippet_name") %>').must_equal 'snippet_name'
            end
            
            it "should return a safe id from 'snippet name'" do
              tag_helpers_app('<%= self.send(:html_safe_id, "snippet name") %>').must_equal 'snippet-name'
            end
            
            it "should return a safe id from 'SnippetName'" do
              tag_helpers_app('<%= self.send(:html_safe_id, "SnippetName") %>').must_equal 'snippetname'
            end
            
            it "should return a safe id from 'Snippet::Category'" do
              tag_helpers_app('<%= self.send(:html_safe_id, "Snippet::Category") %>').must_equal 'snippet-category'
            end
                        
          end
          
          describe '#add_css_class' do
            
            it "should return the combined classes" do
              tag_helpers_app('<%= self.send(:add_css_class, { class: ["alert"]}, ["alert-info"]) %>').must_equal '{:class=>"alert alert-info"}'
            end
            
            it "should handle no {:class} and nil values being passed in" do
              tag_helpers_app('<%= self.send(:add_css_class, {id: :idval}, nil) %>').must_equal '{:id=>:idval, :class=>nil}'
              tag_helpers_app('<%= self.send(:add_css_class, {}, nil) %>').must_equal '{:class=>nil}'
              tag_helpers_app('<%= self.send(:add_css_class, {}, "") %>').must_equal '{:class=>nil}'
            end
            
            it "should handle no {:class} being passed in" do
              tag_helpers_app('<%= self.send(:add_css_class, {}, ["alert-info"]) %>').must_equal '{:class=>"alert-info"}'
            end
            
            it 'should order classes alphabetically' do
              tag_helpers_app('<%= self.send(:add_css_class, { class: "a c d"}, [:e, :b]) %>').must_equal '{:class=>"a b c d e"}'
            end
            
            it 'should handle duplicate class values' do
              tag_helpers_app('<%= self.send(:add_css_class, { class: "alert text"}, [:alert, "alert-info"]) %>').must_equal '{:class=>"alert alert-info text"}'
            end
            
            it 'should handle other attr values' do
              tag_helpers_app('<%= self.send(:add_css_class, { class: "text", id: :idval}, [:alert]) %>').must_equal '{:class=>"alert text", :id=>:idval}'
            end
            
            it 'should handle a mix of string, :symbol and array values being passed' do
              tag_helpers_app('<%= self.send(:add_css_class, { class: "alert text"}, [:alert, "alert-info"]) %>').must_equal '{:class=>"alert alert-info text"}'
            end
            
            it 'should handle combining strings being passed' do
              tag_helpers_app('<%= self.send(:add_css_class, { class: "big"}, "text") %>').must_equal '{:class=>"big text"}'
            end
            
            it 'should handle combining symbols being passed' do
              tag_helpers_app('<%= self.send(:add_css_class, { class: :big}, :text) %>').must_equal '{:class=>"big text"}'
            end
            
            it 'should handle combining strings being passed' do
              tag_helpers_app('<% attrs = {id: :idval, class: :big} %><% attrs = self.send(:add_css_class, attrs, :text) %><%= attrs %>').must_equal '{:id=>:idval, :class=>"big text"}'
            end
            
          end
          
          describe '#add_css_id' do
            
            it "should handle {} and nil values being passed in" do
              tag_helpers_app('<%= self.send(:add_css_id, nil, nil) %>').must_equal '{:id=>nil}'
              tag_helpers_app('<%= self.send(:add_css_id, {}, nil) %>').must_equal '{:id=>nil}'
              tag_helpers_app('<%= self.send(:add_css_id, nil, {}) %>').must_equal '{:id=>nil}'
              tag_helpers_app('<%= self.send(:add_css_id, {}, "") %>').must_equal '{:id=>nil}'
            end
            
            it "should handle {} and nil values being passed in with an id" do
              tag_helpers_app('<%= self.send(:add_css_id, nil, :idval) %>').must_equal '{:id=>"idval"}'
              tag_helpers_app('<%= self.send(:add_css_id, nil, "idval") %>').must_equal '{:id=>"idval"}'
              tag_helpers_app('<%= self.send(:add_css_id, {}, :idval) %>').must_equal '{:id=>"idval"}'
              tag_helpers_app('<%= self.send(:add_css_id, {}, "idval") %>').must_equal '{:id=>"idval"}'
            end
            
            it "should handle values being passed in correctly" do
              tag_helpers_app('<%= self.send(:add_css_id, {}, :name) %>').must_equal    '{:id=>"name"}'
            end
            
            it "should retain and not overwrite the { :id } value passed in" do
              tag_helpers_app('<%= self.send(:add_css_id, {id: :snippet }, :name) %>').must_equal    '{:id=>"snippet"}'
            end
            
          end
          
          describe '#select_options' do
            
            it 'should handle a nil values being passed' do
              tag_helpers_app('<%= self.send(:select_options, nil, nil) %>').must_equal ''
            end
            
            it 'should handle a flat Array [:a,:b,:c] being passed' do
              html = tag_helpers_app('<%= self.send(:select_options, [:a,:b,:c], nil) %>')
              html.must_equal %Q{<option value="a">A</option>\n<option value="b">B</option>\n<option value="c">C</option>\n}
              html.must_have_tag('option[@value=a]', 'A')
              html.must_have_tag('option[@value=b]', 'B')
              html.must_have_tag('option[@value=c]', 'C')
            end
            
            it 'should handle a flat Hash {a: :A,b: :B,c: :C} being passed' do
              html = tag_helpers_app('<%= self.send(:select_options, {a: :A, b: :B, c: :C}, nil) %>')
              html.must_equal %Q{<option value="a">A</option>\n<option value="b">B</option>\n<option value="c">C</option>\n}
              html.must_have_tag('option[@value=a]', 'A')
              html.must_have_tag('option[@value=b]', 'B')
              html.must_have_tag('option[@value=c]', 'C')
            end
            
            it 'should handle a Hash being passed' do
              html = tag_helpers_app('<%= self.send(:select_options, {a: "A", b: "B", c: :C }, nil) %>')
              html.must_equal(%Q{<option value="a">A</option>\n<option value="b">B</option>\n<option value="c">C</option>\n})
              html.must_have_tag('option[@value=a]', 'A')
              html.must_have_tag('option[@value=b]', 'B')
              html.must_have_tag('option[@value=c]', 'C')
            end
            
            it 'should handle a Hash within an Array being passed' do
              html = tag_helpers_app('<%= self.send(:select_options, [[:a,:A],{d: :D},[:c,:C]], nil) %>')
              html.must_equal %Q{<option value="a">A</option>\n<optgroup label="">\n<option value="d">D</option>\n</optgroup>\n<option value="c">C</option>\n}
              html.must_have_tag('option[@value=a]', 'A')
              html.must_have_tag('optgroup > option[@value=d]', 'D')
              html.must_have_tag('option[@value=c]', 'C')
            end
            
          end
          
        end # /private
      
      end # / Instance Methods
      
    end # /RodaTagHelpers
    
  end # /RodaPlugins
    
end # /Roda
