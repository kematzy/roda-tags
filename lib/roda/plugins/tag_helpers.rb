require 'roda'
require_relative '../../core_ext/string' unless String.new.respond_to?(:titleize)
# require_relative '../../core_ext/object' unless :symbol.respond_to?(:in?)

class Roda
  
  module RodaPlugins
    
    module RodaTagHelpers
      # default options
      OPTS = {
        # 
        tags_label_required_str:    '<span>*</span>',
        #
        tags_label_append_str:      ':',
        # the default classes for various form tags. ie: shortcut to automatically add BS3 'form-control'
        tags_forms_default_class:   '', #'form-control',
        
      }.freeze
      
      
      # Depend on the render plugin, since this plugin only makes
      # sense when the render plugin is used.
      def self.load_dependencies(app, opts=OPTS)
        app.plugin :tags, opts
      end
      
      def self.configure(app, opts={})
        if app.opts[:tag_helpers]
          opts = app.opts[:tag_helpers][:orig_opts].merge(opts)
        else
          opts = OPTS.merge(opts)
        end
        
        app.opts[:tag_helpers]             = opts.dup
        app.opts[:tag_helpers][:orig_opts] = opts
      end
      
        
      module ClassMethods
        # Return the uitags options for this class.
        def tag_helpers_opts
          opts[:tag_helpers]
        end
        
      end
      
      module InstanceMethods
        
        ##
        # Constructs a form without object based on options
        # 
        # ==== Examples
        # 
        #   form_tag('/register') do 
        #     ... 
        #   end
        #     #=>
        #       <form action="/register" id="register-form" method="post">
        #         ...
        #       </form>
        # 
        # 
        #   <% form_tag('/register', method: :put, id: 'register-form' ) %>
        #     ...
        #   <% end %>
        #     #=>
        #       <form action="/register" id="register-form" method="post" >
        #         <input name="_method" type="hidden" value="put"/>
        #         ...
        #       </form>
        # 
        # Multipart support via:
        # 
        #   <% form_tag('/register', multipart: true ) %>
        #   
        #   <% form_tag('/register', multipart: 'multipart/form-data' ) %>
        #
        #   <% form_tag('/register', enctype: 'multipart/form-data' ) %>
        #     #=>
        #       <form enctype="multipart/form-data" method="post" action="/register">
        #         ...
        #       </form>
        # 
        def form_tag(action, attrs={}, &block) 
          attrs.reverse_merge!(method: :post, action: action)
          # strip out the method passed in.
          method = attrs[:method]
          # Unless the method is :get, fake out the method using :post
          attrs[:method] = :post unless attrs[:method] == :get
          faux_method_tag = method.to_s =~ /post|get/ ? '' : faux_method(method)
          # set the enctype to multipart-form if we got a @multipart form
          attrs[:enctype] = "multipart/form-data" if attrs.delete(:multipart) || @multipart
          captured_html = block_given? ? capture_html(&block) : ''
          concat_content( tag(:form, faux_method_tag + captured_html , attrs) )
        end
        
        # Constructs a label tag from the given options
        # 
        # ==== Examples
        # 
        #   <%= label_tag(:name) %>
        #     #=>
        #       <label for="name">Name:</label>
        # 
        # 
        # Should accept a custom label text.
        # 
        #   <%= label_tag(:name, label: 'Custom label') %>
        #     #=>
        #       <label for="name">Custom label:</label>
        # 
        # If label value is nil, then renders the default label text.
        # 
        #   <%= label_tag(:name, label: nil) %>
        #     #=>
        #       <label for="name">Name:</label>
        # 
        # Removes the label text when given :false.
        # 
        #   <%= label_tag(:name, label: false) %>
        #     #=>
        #       <label for="name"></label>
        # 
        # Appends the <tt>app.forms_label_required_str</tt> value, when the 
        # label is required.
        # 
        #   <%= label_tag(:name, required: true) %>
        #     #=>
        #       <label for="name">Name: <span>*</span></label>
        # 
        def label_tag(field, attrs={}, &block) 
          attrs.reverse_merge!(label: field.to_s.titleize, for: field)
        
          label_text = attrs.delete(:label)
          # handle FALSE & nil values
          label_text = '' if label_text == false
          label_text = field.to_s.titleize if label_text.nil?
        
          unless label_text.to_s.empty?
            label_text << opts_tag_helpers[:tags_label_append_str]
            label_text = attrs.delete(:required) ? "#{label_text} #{opts_tag_helpers[:tags_label_required_str]}" : label_text
          end
        
          if block_given? # label with inner content
            label_content = label_text + capture_html(&block)
            concat_content(tag(:label, label_content, attrs))
          else # regular label
            tag(:label, label_text, attrs)
          end
        end
        
        # Constructs a hidden field input from the given options
        # 
        # ==== Attributes
        # 
        # * <tt>:value</tt> - Sets the value of this hidden field.
        # * <tt>:id</tt> - The <tt>:id</tt> of the hidden field. Removes id attribute when passed
        #   <tt>:id => false</tt>.
        # * <tt>:name</tt> - Sets the name of the hidden field.
        # 
        # No other attributes allowed for the tag.
        # 
        # ==== Examples
        # 
        #   <%= hidden_field_tag(:snippet_name) %>
        #     #=>
        #       <input id="snippet_name" name="snippet_name" type="hidden">
        #   
        # 
        # Providing a value:
        # 
        #   <%= hidden_field_tag(:snippet_name, value: 'myvalue') %>
        #     #=>
        #       <input id="snippet_name" name="snippet_name" type="hidden" value="myvalue">
        #   
        # 
        # Setting a different <tt>:id</tt>
        # 
        #   <%= hidden_field_tag(:snippet_name, id: 'some-id') %>
        #     #=>
        #       <input id="some-id" name="snippet_name" type="hidden">
        # 
        # 
        # Removing the <tt>:id</tt> attribute completely.
        # 
        #   <%= hidden_field_tag(:snippet_name, id: false ) %>
        #     #=>
        #       <input name="snippet_name" type="hidden">
        #   
        # 
        def hidden_field_tag(name, attrs={}) 
          attrs.reverse_merge!(name: name, value: "", type: :hidden )
          attrs = add_css_id(attrs, name)
          tag(:input, attrs )
        end
        alias_method :hiddenfield_tag, :hidden_field_tag
        
        # Creates a standard text field; use these text fields to input smaller chunks of text like a username or a search query.
        # 
        # ==== Attributes
        # 
        # * <tt>:disabled</tt> - If set to true, the user will not be able to use this input.
        # * <tt>:size</tt> - The number of visible characters that will fit in the input.
        # * <tt>:maxlength</tt> - The maximum number of characters that the browser will allow the user to enter.
        # 
        # Any other key creates standard HTML attributes for the tag.
        # 
        # ==== Examples
        # 
        #   text_field_tag(:snippet_name)
        #     #=> 
        #       <input class="text" id="snippet_name" name="snippet_name" type="text">
        #   
        # 
        # Providing a value:
        # 
        #   text_field_tag(:snippet_name, value: 'some-value')
        #     #=> 
        #       <input class="text" id="snippet_name" name="snippet_name" type="text" value="some-value">
        #   
        # 
        # Setting a different <tt>:id</tt>
        # 
        #   text_field_tag(:snippet_name, id: 'some-id')
        #     #=>
        #       <input class="text" id="some-id" name="snippet_name" type="text">
        # 
        # 
        # Removing the <tt>:id</tt> attribute completely. NB! bad practice.
        # 
        #   text_field_tag(:snippet_name, id: false)
        #     #=>
        #     <input class="text" name="snippet_name" type="text">
        #   
        # 
        # Adding another CSS class. NB! appends the the class to the default class <tt>.text</tt>.
        # 
        #   text_field_tag(:snippet_name, class: :big )
        #     #=>
        #     <input class="big text" id="snippet_name" name="snippet_name" type="text">
        # 
        # 
        # Adds a <tt>:title</tt> attribute when passed <tt>:ui_hint</tt>. Also works with <tt>:title</tt>.
        # 
        #   text_field_tag(:name, ui_hint: 'a user hint')
        #     #=>
        #     <input class="text" id="name" name="name" title="a user hint" type="text">
        # 
        # 
        # Supports <tt>:maxlength</tt> & <tt>:size</tt> attributes.
        # 
        #   text_field_tag(:ip_address, maxlength: 15, size: 20)
        #     #=>
        #     <input class="text" id="ip_address" maxlength="15" name="ip_address" size="20" type="text">
        # 
        # Supports <tt>:disabled</tt> & <tt>:readonly</tt> attributes.
        # 
        #   text_field_tag(:name, disabled: true)
        #     #=>
        #       <input class="text" disabled="disabled" id="name" name="name" type="text" >
        # 
        #   text_field_tag(:name, readonly: true)
        #     #=>
        #     <input class="text" id="name" name="name" readonly="readonly" type="text">
        # 
        #
        def text_field_tag(name, attrs={}) 
          attrs.reverse_merge!(name: name, type: :text)
          attrs = add_css_id(attrs, name)
          
          attrs = add_css_class(attrs, :text)
          # attrs[:class] = attrs[:class].nil? ? [:text] : [ attrs[:class], :text ]
          # attrs[:class]      = [:text]
          
          # attrs[:class] = merge_classes(attrs[:class], :text)
          attrs = add_ui_hint(attrs)
          tag(:input, attrs )
        end
        alias_method :textfield_tag, :text_field_tag
        
        # Constructs a password field input from the given options
        # 
        # ==== Examples
        # 
        # 
        #   password_field_tag(:snippet_name)
        #     #=>
        #       <input class="text" id="snippet_name" name="snippet_name" type="password">
        #   
        # 
        # Providing a value:
        # 
        #   password_field_tag(:snippet_name, value: 'some-value')
        #     #=>
        #       <input class="text" id="snippet_name" name="snippet_name" type="password" value="some-value">
        #   
        # 
        # Setting a different <tt>:id</tt>
        # 
        #   password_field_tag(:snippet_name, id: 'some-id')
        #     #=>
        #       <input class="text" id="some-id" name="snippet_name" type="password">
        #     
        #  
        # Removing the <tt>:id</tt> attribute completely. NB! bad practice.
        # 
        #   password_field_tag(:snippet_name, id: false)
        #     #=>
        #       <input class="text" name="snippet_name" type="password">
        #      
        # 
        # Adding another CSS class. NB! appends the the class to the default class <tt>.text</tt>.
        # 
        #   password_field_tag(:snippet_name, class: :big )
        #     #=>
        #       <input class="big text" id="snippet_name" name="snippet_name" type="password">
        # 
        # 
        # Adds a <tt>:title</tt> attribute when passed <tt>:ui_hint</tt>. Also works with <tt>:title</tt>.
        # 
        #   password_field_tag(:name, ui_hint: 'a user hint')
        #     #=>
        #       <input class="text" id="name" name="name" title="a user hint" type="password">
        # 
        # 
        # Supports <tt>:maxlength</tt>, <tt>:size</tt> & <tt>:disabled</tt> attributes.
        # 
        #   password_field_tag(:ip_address, maxlength: 15, size: 20)
        #     #=>
        #       <input class="text" id="ip_address" maxlength="15" name="ip_address" size="20" type="password">
        # 
        #   password_field_tag(:name, disabled: true)
        #     #=>
        #       <input class="text" id="name" disabled="disabled" name="name" type="password">
        # 
        def password_field_tag(name, attrs={}) 
          attrs.reverse_merge!(name: name, type: :password)
          attrs = add_css_id(attrs, name)
          attrs = add_css_class(attrs, :text) # deliberately giving it the .text class
          attrs = add_ui_hint(attrs)
          tag(:input, attrs )
        end
        alias_method :passwordfield_tag, :password_field_tag
        
        
        # Creates a file upload field. If you are using file uploads then you will also 
        # need to set the multipart option for the form tag:
        # 
        #   <% form_tag '/upload', :multipart => true do %>
        #     <label for="file">File to Upload</label>
        #     <%= file_field_tag "file" %>
        #     <%= submit_tag %>
        #   <% end %>
        # 
        # The specified URL will then be passed a File object containing the selected file, 
        # or if the field was left blank, a StringIO object.
        # 
        # ==== Attributes
        # 
        # Creates standard HTML attributes for the tag.
        # * <tt>:disabled</tt> - If set to true, the user will not be able to use this input.
        # 
        # ==== Examples
        # 
        #   file_field_tag('attachment')
        #     #=> 
        #       <input class="file" id="attachment" name="attachment" type="file">
        # 
        # Ignores the invalid <tt>:value</tt> attribute.
        # 
        #   file_field_tag(:photo, value: 'some-value')
        #     #=>
        #       <input class="file" id="photo" name="photo" type="file">
        # 
        # Setting a different <tt>:id</tt>
        # 
        #   file_field_tag(:photo, id: 'some-id')
        #     #=>
        #       <input class="file" id="some-id" name="photo" type="file">
        # 
        # Removing the <tt>:id</tt> attribute completely. NB! bad practice.
        # 
        #   file_field_tag(:photo, id: false)
        #     #=>
        #       <input class="file" name="photo" type="file">
        #   
        # 
        # Adding another CSS class. NB! appends the the class to the default class <tt>.text</tt>.
        # 
        #   file_field_tag(:photo, class: :big )
        #     #=>
        #       <input class="big file" id="photo" name="photo" type="file">
        # 
        # 
        # Adds a <tt>:title</tt> attribute when passed <tt>:ui_hint</tt>. Also works with <tt>:title</tt>.
        # 
        #   file_field_tag(:photo, ui_hint: 'a user hint')
        #     #=>
        #       <input class="file" id="photo" name="photo" title="a user hint" type="file">
        #   
        # 
        # Supports the <tt>:disabled</tt> attribute.
        # 
        #   file_field_tag(:photo, disabled: true)
        #     #=> 
        #       <input class="file" disabled="disabled" id="photo" name="photo" type="file">
        #   
        # 
        # Supports the <tt>:accept</tt> attribute, even though most browsers don't.
        # 
        #   file_field_tag(:photo, accept: 'image/png,image/jpeg' )
        #     #=> 
        #      <input accept="image/png,image/jpeg" class="file" id="photo" name="photo" type="file">
        # 
        def file_field_tag(name, attrs={}) 
          attrs.reverse_merge!(name: name, type: :file)
          attrs.delete(:value) # can't use value, so delete it if present
          attrs = add_css_id(attrs, name)
          attrs = add_css_class(attrs, :file)
          attrs = add_ui_hint(attrs)
          tag(:input, attrs )
        end
        alias_method :filefield_tag, :file_field_tag
        
        
        # Constructs a textarea input from the given options
        # 
        # ==== Attributes 
        #  
        # * <tt>:size</tt> - A string specifying the dimensions (columns by rows) of the textarea (e.g., “25x10”).
        # * <tt>:rows</tt> - Specify the number of rows in the textarea
        # * <tt>:cols</tt> - Specify the number of columns in the textarea
        # * <tt>:disabled</tt> - If set to true, the user will not be able to use this input.
        # 
        # TODO: enable :escape functionality...
        # 
        # * <tt>:escape</tt> - By default, the contents of the text input are HTML escaped. If you need unescaped contents, set this to false.
        # 
        # Any other key creates standard HTML attributes for the tag.
        #
        # ==== Examples
        # 
        #   textarea_tag('post')
        #     #=> 
        #       <textarea id="post" name="post">\n</textarea>
        # 
        # Providing a value:
        # 
        #   textarea_tag(:bio, value: @actor.bio)
        #     #=> 
        #       <textarea id="bio" name="bio">This is my biography.\n</textarea>
        # 
        # Setting a different <tt>:id</tt>
        # 
        #   textarea_tag(:body, id: 'some-id')
        #     #=>
        #       <textarea id="some-id" name="post">\n\n</textarea>
        #    
        # Adding a CSS class. NB! textarea has no other class by default.
        #  
        #   textarea_tag(:body, class: 'big')
        #     #=>
        #       <textarea class="big" id="post" name="post">\n</textarea>
        #   
        # 
        # Adds a <tt>:title</tt> attribute when passed <tt>:ui_hint</tt>. Also works with <tt>:title</tt>.
        # 
        #   textarea_tag(:body, ui_hint: 'a user hint')
        #     #=>
        #       <textarea id="post" name="post" title="a user hint">\n</textarea>
        #   
        # 
        # Supports <tt>:rows</tt> & <tt>:cols</tt> attributes.
        # 
        #   textarea_tag('body', rows: 10, cols: 25)
        #     #=> 
        #       <textarea cols="25" id="body" name="body" rows="10">\n</textarea>
        #   
        # 
        # Supports shortcut to <tt>:rows</tt> & <tt>:cols</tt> attributes, via the <tt>:size</tt> attribute.
        # 
        #   textarea_tag( 'body', size: "25x10")
        #     #=> 
        #       <textarea cols="25" id="body" name="body" rows="10"></textarea>
        #     
        # 
        # Supports <tt>:disabled</tt> & <tt>:readonly</tt> attributes.
        # 
        #   textarea_tag(:description, disabled: true)
        #     #=> 
        #       <textarea disabled="disabled" id="description" name="description"></textarea>
        #   
        #   textarea_tag(:description, readonly: true)
        #     #=> 
        #       <textarea id="description" name="description" readonly="readonly"></textarea>
        #   
        def textarea_tag(name, attrs={}) 
          attrs.reverse_merge!(:name => name)
          attrs = add_css_id(attrs, name)
          if size = attrs.delete(:size)
            attrs[:cols], attrs[:rows] = size.split("x") if size.respond_to?(:split)
          end
          content = attrs.delete(:value)
          attrs = add_ui_hint(attrs)
          tag(:textarea, content, attrs )
        end
        alias_method :text_area_tag, :textarea_tag
        
        # Creates a field set for grouping HTML form elements.
        # 
        # ==== Examples
        # 
        #   <% field_set_tag(:actor) %>
        #     #=>
        #       <fieldset id="fieldset-actor">
        #          ...
        #       </fieldset>
        #   
        # Sets the <tt><legend></tt> and <tt>:id</tt> attribute when given a single argument.
        # 
        #   <% field_set_tag 'User Details' do %>
        #     <p><%= text_field_tag 'name' %></p>
        #   <% end %>
        #     #=>
        #       <fieldset id="fieldset-user-details">
        #         <legend>User Details</legend>
        #         <p><input name="name" class="text" id="name" type="text"></p>
        #       </fieldset>
        # 
        # 
        # Supports <tt>:legend</tt> attribute for the <tt><legend></tt> tag.
        # 
        #   field_set_tag(:actor, legend: 'Your Details')
        #     #=>
        #       <fieldset id="fieldset-actor">
        #         <legend>Your Details</legend>
        #         <snip...>
        #   
        # 
        # Adding a CSS class. NB! fieldset has no other class by default.
        # 
        #   field_set_tag(:actor, class: "legend-class")
        #     #=>
        #       <fieldset class="legend-class" id="fieldset-actor">
        #         <snip...>
        # 
        # 
        # When passed +nil+ as the first argument the <tt>:id</tt> becomes 'fieldset'.
        # 
        #   field_set_tag( nil, class: 'format')
        #     #=> 
        #       <fieldset class="format" id="fieldset">
        #         <snip...>
        # 
        # Removing the <tt>:id</tt> attribute completely.
        # 
        #   field_set_tag('User Details', id: false)
        #     #=> 
        #       <fieldset>
        #         <legend>User Details</legend>
        #         <snip...>
        # 
        # @api public
        def field_set_tag(*args, &block) 
          attrs = args.last.is_a?(::Hash) ? args.pop : {}
          attrs = add_css_id(attrs, ['fieldset',args.first].compact.join('-') )
          legend_text = args.first.is_a?(String || Symbol) ? args.first : attrs.delete(:legend)
          legend_html = legend_text.blank? ? '' : tag(:legend, legend_text)
          captured_html = block_given? ? capture_html(&block) : ''
          concat_content( tag(:fieldset, legend_html + captured_html, attrs ))
        end
        alias_method :fieldset_tag, :field_set_tag
        
        
        # Return a legend with _contents_.
        # 
        # ==== Examples
        # 
        #   legend_tag('User Details')
        #     #=>
        #       <legend>User Details</legend>
        # 
        # Adding an :id attribute.
        # 
        #   legend_tag('User Details', id: 'some-id')
        #     #=>
        #       <legend id="some-id">User Details</legend>
        # 
        # 
        # Adding a CSS class. NB! legend has no other class by default.
        # 
        #   legend_tag('User Details', class: 'some-class')
        #     #=>
        #       <legend class="some-class">User Details</legend>
        # 
        def legend_tag(contents, attrs={}) 
          tag(:legend, contents, attrs)
        end
        
        # Creates a checkbox element.
        # 
        # ==== Attributes
        # 
        # * <tt>:disabled</tt> - If set to true, the user will not be able to use this input.
        # * <tt>:checked</tt> - If set to true, the checkbox is checked.
        # 
        # Any other key creates standard HTML options for the tag.
        # 
        # ==== Examples
        #   
        #   check_box_tag(:accept)
        #     #=>
        #       <input class="checkbox" id="accept" name="accept" type="checkbox" value="1">
        #   
        # 
        # Providing a value:
        # 
        #   check_box_tag(:rock, value: 'rock music')
        #     #=> 
        #       <input class="checkbox" id="rock" name="rock" type="checkbox" value="rock music">
        # 
        # Setting a different <tt>:id</tt>.
        # 
        #   check_box_tag(:rock, :id => 'some-id')
        #     #=> 
        #       <input class="checkbox" id="some-id" name="rock" type="checkbox" value="1">
        # 
        # 
        # Adding another CSS class. NB! appends the the class to the default class <tt>.checkbox</tt>.
        # 
        #   check_box_tag(:rock, class: 'small')
        #     #=> 
        #       <input class="small checkbox" id="rock" name="rock" type="checkbox" value="1">
        #   
        # 
        # Adds a <tt>:title</tt> attribute when passed <tt>:ui_hint</tt>. Also works with <tt>:title</tt>.
        # 
        #   check_box_tag(:rock, ui_hint: 'a user hint')
        #     #=> 
        #       <input class="checkbox" id="rock" name="rock" title="a user hint" type="checkbox" value="1">
        # 
        # Supports the <tt>:disabled</tt> & <tt>:checked</tt> attributes.
        # 
        #   check_box_tag(:rock, checked: true)
        #     #=> 
        #       <input checked="checked" class="checkbox" id="rock" name="rock" type="checkbox" value="1">
        # 
        # 
        #   check_box_tag(:rock, disabled: true)
        #     #=> 
        #       <input class="checkbox" disabled="disabled" id="rock" name="rock" type="checkbox" value="1">
        # 
        def check_box_tag(name, attrs={}) 
          attrs.reverse_merge!(name: name, type: :checkbox, checked: false, value: 1)
          attrs = add_css_id(attrs, name)
          attrs = add_css_class(attrs, :checkbox)
          attrs = add_ui_hint(attrs)
          tag(:input, attrs )
        end
        alias_method :checkbox_tag, :check_box_tag
        
        # Creates a radio button; use groups of radio buttons named the same to allow users to select 
        # from a group of options.
        # 
        # ==== Attributes
        # 
        # * <tt>:disabled</tt> - If set to true, the user will not be able to use this input.
        # 
        # Any other key creates standard HTML options for the tag.
        # 
        # ==== Examples
        #   
        #   radio_button_tag(:accept)
        #     #=>
        #       <input class="radio" id="accept_1" name="accept" type="radio" value="1">
        #   
        # 
        # Providing a value:
        # 
        #   radio_button_tag( :rock, value: 'rock music')
        #     #=> 
        #       <input class="radio" id="rock_rock-music" name="rock" type="radio" value="rock music">
        #   
        # 
        # Setting a different <tt>:id</tt>.
        # 
        #   radio_button_tag( :rock, id: 'some-id')  
        #     #=>
        #       <input class="radio" id="some-id_1" name="rock" type="radio" value="1">
        #   
        # 
        # Adding another CSS class. NB! appends the the class to the default class <tt>.radio</tt>.
        # 
        #   radio_button_tag( :rock, class: 'big')  
        #     #=>
        #       <input class="big radio" id="rock_1" name="rock" type="radio" value="1">
        #   
        # 
        # Adds a <tt>:title</tt> attribute when passed <tt>:ui_hint</tt>. Also works with <tt>:title</tt>.
        # 
        #   radio_button_tag( :rock, ui_hint: 'a user hint')  
        #     #=>
        #       <input class="radio" id="rock_1" value="1" name="rock" title="a user hint" type="radio">
        # 
        # 
        # Supports the <tt>:disabled</tt> & <tt>:checked</tt> attributes.
        # 
        #   radio_button_tag(:yes, checked: true)
        #     #=> <input checked="checked" class="checkbox" id="yes_1" name="yes" type="checkbox" value="1">
        # 
        #   radio_button_tag(:yes, disabled: true)
        #     #=> <input disabled="disabled" class="checkbox" id="yes_1" name="yes" type="radio" value="1">
        # 
        # 
        def radio_button_tag(name, attrs={}) 
          attrs.reverse_merge!(name: name, type: :radio, checked: false, value: 1)
          attrs = add_css_id(attrs, name)
          # id_value = [field.to_s,'_',value].join
          attrs[:id] = [attrs[:id], html_safe_id(attrs[:value]) ].compact.join('_')
          attrs = add_css_class(attrs, :radio)
          attrs = add_ui_hint(attrs)
          tag(:input, attrs )
        end
        alias_method :radiobutton_tag, :radio_button_tag
        
        # Creates a submit button with the text value as the caption.
        # 
        # ==== Examples
        # 
        #   <%= submit_tag %> || <%= submit_button %>
        #     => <input name="submit" type="submit" value="Save Form">
        #
        #   <%= submit_tag(nil) %>
        #     => <input name="submit" type="submit" value="">
        #   
        #   <%= submit_tag("Custom Value") %>
        #     => <input name="submit" type="submit" value="Custom Value">
        #   
        # 
        # Adding a CSS class. NB! input[:submit] has no other class by default.
        # 
        #   <%= submit_tag(class: 'some-class') %>
        #     #=> <input class="some-class" name="submit" type="submit" value="Save Form">
        #
        # 
        # Supports the <tt>:disabled</tt> attribute.
        # 
        #   <%= submit_tag(disabled: true) %>
        #     #=> <input disabled="disabled" name="submit" type="submit" value="Save Form">
        #   
        # 
        # Adds a <tt>:title</tt> attribute when passed <tt>:ui_hint</tt>. Also works with <tt>:title</tt>.
        # 
        #   <%= submit_tag(ui_hint: 'a user hint') %>
        #     #=> <input name="submit" title="a user hint" type="submit" value="Save Form">
        # 
        # 
        def submit_tag(value="Save Form", attrs={}) 
          value, attrs = "Save Form", value if value.is_a?(Hash)
          attrs.reverse_merge!(type: :submit, name: :submit, value: value )
          attrs = add_ui_hint(attrs)
          self_closing_tag(:input, attrs)
        end
        alias_method :submit_button, :submit_tag
      
        ##
        # Displays an image which when clicked will submit the form.
        #  
        # ==== Examples
        #   
        #   @img = '/img/btn.png'
        # 
        #   image_submit_tag(@img)
        #     #=> <input src="/img/btn.png" type="image">
        # 
        #   image_submit_tag(@img, disabled: true)
        #     #=> <input disabled="disabled" src="/img/btn.png" type="image">
        # 
        #   image_submit_tag(@img, class 'search-button')
        #     #=> <input class="search-button" src="/img/btn.png" type="image">
        # 
        def image_submit_tag(src, attrs = {})
          tag(:input, { type: :image, src: src }.merge(attrs) )
        end
        alias_method :imagesubmit_tag, :image_submit_tag
        
      
        ##
        # Creates a reset button with the text value as the caption.
        # 
        # ==== Attributes
        # 
        # * <tt>:disabled</tt> - If true, the user will not be able to use this input.
        # * <tt>:disabled</tt> - If true, the user will not be able to use this input.
        # 
        # Any other key creates standard HTML options for the tag.
        # 
        # ==== Examples
        # 
        #   <%= reset_tag %>
        #     => <input name="reset" type="reset" value="Reset Form">
        #
        #   <%= reset_tag(nil) %>
        #     => <input name="reset" type="reset" value="">
        #   
        # 
        # Adding a CSS class. NB! input[:reset] has no other class by default.
        # 
        #   <%= reset_tag('Custom Value', class: 'some-class') %>
        #     => <input class="some-class" name="reset" type="reset" value="Custom Value" >
        #   
        # 
        # Supports the <tt>:disabled</tt> attribute.
        #   
        #   <%= reset_tag('Custom Value', disabled: true) %>
        #     => <input disabled="disabled" name="reset" type="reset" value="Custom Value"> 
        #   
        # 
        # Adds a <tt>:title</tt> attribute when passed <tt>:ui_hint</tt>. Also works with <tt>:title</tt>.
        # 
        #   <%= reset_tag('Custom Value', ui_hint: 'a user hint') %>
        #     => <input name="reset" title="a user hint" type="submit" value="Custom Value">
        # 
        # 
        def reset_tag(value = 'Reset Form', attrs={})
          value, attrs =  "Reset Form", value if value.is_a?(Hash)           
          attrs.reverse_merge!(type: :reset, name: :reset, value: value )
          attrs = add_ui_hint(attrs)
          self_closing_tag(:input, attrs)
        end
        alias_method :reset_button, :reset_tag
        
        # Creates a dropdown selection menu.
        # 
        # If the :multiple option is set to true, a multiple choice selection box
        # is created.
        # 
        # ==== Attributes
        # 
        # * <tt>:multiple</tt> - If set to true the selection will allow multiple choices.
        # * <tt>:disabled</tt> - If set to true, the user will not be able to use this input.
        # 
        # Any other key creates standard HTML attributes for the tag.
        # 
        # 
        # ==== Examples
        #
        # NB! the format for the options values must be [value, key].
        # 
        # With Options values as a Hash
        # 
        #   select_tag(:letters, {a: 'A', b: 'B' })
        #     #=> 
        #       <select id="letters" name="letters">
        #         <option value="a">A</option>
        #         <option value="b">B</option>
        #       </select>
        #
        # With Options values as an Array
        # 
        #   @letters = [[:a,'A'], [:b,'B']]
        # 
        #   select_tag(:letters, @letters)
        #     #=> 
        #       <select id="letters" name="letters">
        #         <option value="a">A</option>
        #         <option value="b">B</option>
        #       </select>
        #
        # 
        # With Options values as an Array
        # 
        #   select_tag(:letters, @letters, selected: :a )
        #     #=> 
        #       <select id="letters" name="letters">
        #         <option selected="selected" value="a">A</option>
        #         <snip...>
        #   
        # 
        # When passing multiple items to :selected, the select menu automatically becomes 
        # a multiple select box. <b>NB! the [] on the <tt>:name</tt> attribute</b>
        # 
        #   select_tag(:letters, @letters, selected: [:a,'b'] )
        #     #=> 
        #       <select id="letters" multiple="multiple" name="letters[]">
        #         <option selected="selected" value="a">A</option>
        #         <option selected="selected" value="b">B</option>
        #       </select>
        #   
        # 
        # When setting :multiple => true, the select menu becomes a select box allowing multiple choices. 
        # <b>NB! the [] on the <tt>:name</tt> attribute</b>
        # 
        #   select_tag(:letters, @letters, multiple: true )
        #     #=> 
        #       <select id="letters" name="letters[]" multiple="multiple">
        #         <snip...>
        # 
        # 
        #   select_tag(:letters, @letters, disabled: true )
        #     #=>  
        #       <select id="letters" disabled="disabled" name="letters">
        #         <snip...>
        #       
        # 
        #   select_tag(:letters, @letters, id: 'my-letters' )
        #     #=>  
        #       <select id="my-letters" name="letters">
        #         <snip...>
        # 
        # 
        #   select_tag(:letters, @letters, class: 'funky-select' )
        #     #=>  
        #       <select class="funky-select" id="my-letters" name="letters">
        #         <snip...>
        # 
        # 
        #   select_tag(:letters, @letters, prompt: true )
        #     #=>  
        #       <select id="letters" name="letters">
        #         <option selected="selected" value="">- Select -</option>
        #         <snip...>
        #   
        # 
        #   select_tag(:letters, @letters, prompt: 'Top Letters', selected: 'a' )
        #     #=>    
        #       <select id="letters" name="letters">
        #         <option value="">Top Letters</option>
        #         <option selected="selected" value="a">A</option>
        #         <snip...>
        # 
        # 
        def select_tag(name, options, attrs={}) 
          options = options.to_a.reverse if options.is_a?(Hash)
        
          attrs[:multiple] = true if attrs[:selected].is_a?(Array)
        
          options_html = select_options(options, attrs)
          attrs.delete(:selected)
          # attrs = add_css_id(attrs, name)
          add_css_id(attrs, name)
          html_name = (attrs[:multiple] == true && !name.to_s.end_with?("[]")) ? "#{name}[]" : name
        
          tag(:select, options_html, { name: html_name }.merge(attrs) )
        end
      

        # Return select option _contents_ with _value_.
        # 
        # ==== Examples
        # 
        #   select_option('a', 'Letter A')  #=>  <option value="a">Letter A</option>
        # 
        # 
        #   select_option('on', '')  #=>  <option value="on">On</option>
        # 
        #   select_option('a', 'Letter A', selected: true)
        #     #=> <option selected="selected" value="a">Letter A</option>
        # 
        # 
        #   select_option('a', 'Letter A', selected: false)
        #     #=> <option value="a">Letter A</option>
        # 
        # 
        def select_option(value, key, attrs={})
          key = value.to_s.titleize if key.blank?
          tag(:option, key, { value: value }.merge(attrs) )
        end
        
        
        # Support Rack::MethodOverride
        # 
        def faux_method(method='PUT')
          hidden_field_tag(:input, name: "_method", value: method.to_s.upcase)
          # self_closing_tag(:input, type: "hidden", name: "_method", value: method)
        end
        
        
        
        private
        
        # 
        def opts_tag_helpers
          opts[:tag_helpers]
        end
        
        #
        def html_safe_id(id) 
          id.to_s.downcase.gsub(/\W/,'-').gsub('--','-')
        end
        
        # do we have a class attrs already
        def add_css_class(attrs, new_class=nil)
          attrs = merge_attr_classes(attrs, new_class)
        end
        
        #
        def add_css_id(attrs, new_id) 
          attrs = {} if attrs.nil?
          new_id = '' if new_id.is_a?(Hash)
          id_value = attrs[:id].nil?  ?  html_safe_id(new_id.to_s) : attrs.delete(:id) 
          attrs[:id] = id_value.to_s unless id_value === false
          attrs[:id] = nil if attrs[:id] === '' # set to nil to remove from tag output
          attrs
        end
        
        #
        def add_ui_hint(attrs) 
          attrs[:title] = attrs.delete(:ui_hint) unless attrs[:ui_hint].nil?
          attrs
        end
        
        # Return select option elements from _values_ with _options_ passed. 
        #
        # === Options
        # 
        #   :selected    string, symbol, or array of options selected
        # 
        # ==== Examples
        # 
        # 
        def select_options(values, attrs={})
          attrs = {} if attrs.blank? 
          values = [] if values.blank?
          normalize_select_prompt(values, attrs)
          # { :a => 'A' }
          # [5, 'E']
          #  FIXME:: when passed a Hash of values, they become reversed (last first and so on..) 
          
          values.map do |value, key| 
            if value.is_a?(Hash)
              tag( :optgroup, select_options(value, attrs), label: key )
            elsif option_selected?(value, attrs[:selected])
              select_option(value, key, selected: true)
            else
              select_option(value, key)
            end
          end.join
        end
        
        # Normalize select prompt. 
        #
        # * When +attrs+ contains a :prompt string it is assigned as the prompt
        # * When :prompt is true the default of '- Select Model -' will become the prompt
        # * The prompt is selected unless a specific option is explicitly selected.
        # 
        def normalize_select_prompt(values, attrs={}) 
          return unless attrs.has_key?(:prompt)
          prompt = attrs.delete(:prompt)
          attrs[:selected] = '' unless attrs.include?(:selected)
          prompt_text = prompt === true ? '- Select -' : prompt
          values.unshift(['', prompt_text])
        end
        
        # Check if option _key_ is _selected_.
        def option_selected?(key, selection) 
          if Array === selection 
            ( selection.map {|s| s.to_s } ).include?(key.to_s)
          else
            selection.to_s == key.to_s
          end
        end
        
        
      end # /InstanceMethods
      
    end # /RodaTagHelpers
    
    register_plugin(:tag_helpers, RodaTagHelpers)
    
  end # /RodaPlugins
  
end