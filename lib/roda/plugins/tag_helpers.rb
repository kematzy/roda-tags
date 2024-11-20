# frozen_string_literal: true

require 'roda'
require_relative '../../core_ext/string' unless ''.respond_to?(:titleize)
# require_relative '../../core_ext/object' unless :symbol.respond_to?(:in?)

class Roda
  # add module documentation
  module RodaPlugins
    # add module documentation
    module RodaTagHelpers
      # default options
      OPTS = {
        tags_label_required_str: '<span>*</span>',
        tags_label_append_str: ':',
        # the default classes for various form tags. ie: shortcut to automatically add
        # BS3 'form-control'
        tags_forms_default_class: '' # 'form-control',

      }.freeze

      # Depend on the render plugin, since this plugin only makes
      # sense when the render plugin is used.
      def self.load_dependencies(app, opts = OPTS)
        app.plugin :tags, opts
      end

      # Configure the tag_helpers plugin with given options.
      #
      # @param app [Class] The Roda app class
      # @param opts [Hash] Configuration options to merge with defaults
      #   If tag_helpers is already configured, merges with existing options
      #   Otherwise merges with OPTS constant defaults
      #
      # @return [void]
      #
      def self.configure(app, opts = {})
        opts = if app.opts[:tag_helpers]
                 app.opts[:tag_helpers][:orig_opts].merge(opts)
               else
                 OPTS.merge(opts)
               end

        app.opts[:tag_helpers]             = opts.dup
        app.opts[:tag_helpers][:orig_opts] = opts
      end

      # add module documentation
      module ClassMethods
        # Return the uitags options for this class.
        def tag_helpers_opts
          opts[:tag_helpers]
        end
      end

      # add module documentation
      # rubocop:disable Metrics/ModuleLength
      module InstanceMethods
        # Constructs a form tag with given action and attributes
        #
        # @param action [String] The URL/path the form submits to
        # @param attrs [Hash] HTML attributes for the form tag
        # @param block [Block] Optional block containing form content
        #
        # @return [String] The generated HTML form tag and contents
        #
        # @example Basic usage
        #
        #   form_tag('/register') do
        #     # form contents
        #   end
        #     #=> <form action="/register" method="post">
        #     #     ...
        #     #   </form>
        #
        #   form_tag('/register', id: :register-form, class: 'form-control') do
        #     ...
        #   end
        #     #=> <form action="/register" method="post" id="register-form" class="form-control">
        #     #     ...
        #     #   </form>
        #
        # @example Custom methods PUT/DELETE
        #
        #   form_tag('/items', method: :put) do
        #     ...
        #   end
        #     #=> <form action="/items" method="post">
        #     #     <input name="_method" type="hidden" value="PUT" />
        #     #   </form>
        #
        # @example Multipart forms
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
        def form_tag(action, attrs = {}, &block)
          attrs.reverse_merge!(method: :post, action: action)
          method = attrs[:method]

          # Unless the method is :get, fake out the method using :post
          attrs[:method] = :post unless attrs[:method] == :get
          faux_method_tag = /post|get/.match?(method.to_s) ? '' : faux_method(method)

          # set the enctype to multipart-form if we got a @multipart form
          attrs[:enctype] = 'multipart/form-data' if attrs.delete(:multipart) || @multipart
          captured_html = block_given? ? capture_html(&block) : ''
          concat_content(tag(:form, faux_method_tag + captured_html, attrs))
        end

        # Constructs a label tag from the given options
        #
        # @example Basic usage
        #
        #   <%= label_tag(:name) %>
        #     #=>  <label for="name">Name:</label>
        #
        # @example Should accept a custom label text.
        #
        #   <%= label_tag(:name, label: 'Custom label') %>
        #     #=> <label for="name">Custom label:</label>
        #
        # @example If label value is nil, then renders the default label text.
        #
        #   <%= label_tag(:name, label: nil) %>
        #     #=> <label for="name">Name:</label>
        #
        # @example Removes the label text when given :false.
        #
        #   <%= label_tag(:name, label: false) %>
        #     #=> <label for="name"></label>
        #
        # @example Appends the `app.forms_label_required_str` value, when the label is required.
        #
        #   <%= label_tag(:name, required: true) %>
        #     #=> <label for="name">Name: <span>*</span></label>
          attrs.reverse_merge!(label: field.to_s.titleize, for: field)
        
        #
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def label_tag(field, attrs = {}, &block)
          label_text = attrs.delete(:label)
          # handle FALSE & nil values
          label_text = '' if label_text == false
          label_text = field.to_s.titleize if label_text.nil?
        
          unless label_text.to_s.empty?
            label_text << opts_tag_helpers[:tags_label_append_str]
            if attrs.delete(:required)
              label_text = "#{label_text} #{opts_tag_helpers[:tags_label_required_str]}"
            end
          end

          if block_given? # label with inner content
            label_content = label_text + capture_html(&block)
            concat_content(tag(:label, label_content, attrs))
          else # regular label
            tag(:label, label_text, attrs)
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        # Constructs a hidden field input from the given options
        #
        # @param name [String] The field name used for :id & :name attributes
        # @param attrs [Hash] HTML attributes for the input[@type=hidden] tag
        #
        # @return [String] The generated HTML input[@type=hidden] tag
        #
        # @example Basic usage
        #
        #   <%= hidden_field_tag(:snippet_name) %>
        #     #=>
        #       <input id="snippet_name" name="snippet_name" type="hidden">
        #
        # @example Providing a value:
        #
        #   <%= hidden_field_tag(:snippet_name, value: 'myvalue') %>
        #     #=>
        #       <input id="snippet_name" name="snippet_name" type="hidden" value="myvalue">
        #
        # @example Setting a different `:id`
        #
        #   <%= hidden_field_tag(:snippet_name, id: 'some-id') %>
        #     #=>
        #       <input id="some-id" name="snippet_name" type="hidden">
        #
        # @example Removing the `:id` attribute completely.
        #
        #   <%= hidden_field_tag(:snippet_name, id: false ) %>
        #     #=>
        #       <input name="snippet_name" type="hidden">
        #
        def hidden_field_tag(name, attrs = {})
          attrs.reverse_merge!(name: name, value: '', type: :hidden)
          attrs = add_css_id(attrs, name)
          tag(:input, attrs)
        end
        alias hiddenfield_tag hidden_field_tag

        # Creates a standard text field; use these text fields to input smaller chunks of text like
        # a username or a search query.
        #
        # @param name [String] The field name used for :id & :name attributes
        # @param attrs [Hash] HTML attributes for the input[@type=text] tag
        #
        # @return [String] The generated HTML input[@type=text] tag
        #
        # @example Basic usage
        #   text_field_tag(:snippet_name)
        #     #=>  <input class="text" id="snippet_name" name="snippet_name" type="text">
        #
        # @example With a value
        #   text_field_tag(:snippet, value: 'some-value')
        #     #=>  <input class="text" id="snippet" name="snippet" type="text" value="some-value">
        #
        # @example Setting a different `:id`
        #   text_field_tag(:snippet_name, id: 'some-id')
        #     #=>  <input class="text" id="some-id" name="snippet_name" type="text">
        #
        # @example Removing the `:id` attribute completely.
        # NOTE! bad practice.
        #
        #   text_field_tag(:snippet_name, id: false)
        #     #=>  <input class="text" name="snippet_name" type="text">
        #
        # @example Adding another CSS class.
        #  NOTE! appends the the class to the default class `.text`.
        #
        #   text_field_tag(:snippet_name, class: :big )
        #     #=>  <input class="big text" id="snippet_name" name="snippet_name" type="text">
        #
        # @example Adds a `:title` attribute when passed `:ui_hint`.
        #   text_field_tag(:name, ui_hint: 'a user hint')
        #     #=>  <input class="text" id="name" name="name" title="a user hint" type="text">
        #
        # @example Supports `:maxlength` & `:size` attributes.
        #   text_field_tag(:ip, maxlength: 15, size: 20)
        #     #=>  <input class="text" id="ip" maxlength="15" name="ip" size="20" type="text">
        #
        # @example Supports `:disabled` & `:readonly` attributes.
        #   text_field_tag(:name, disabled: true)
        #     #=>  <input class="text" disabled="disabled" id="name" name="name" type="text" >
        #
        #   text_field_tag(:name, readonly: true)
        #     #=>  <input class="text" id="name" name="name" readonly="readonly" type="text">
        #
        def text_field_tag(name, attrs = {})
          attrs.reverse_merge!(name: name, type: :text)
          attrs = add_css_id(attrs, name)
          attrs = add_css_class(attrs, :text)
          attrs = add_ui_hint(attrs)
          tag(:input, attrs)
        end
        alias textfield_tag text_field_tag

        # Constructs a password field input from the given options
        #
        # @param name [String] The field name used for :id & :name attributes
        # @param attrs [Hash] HTML attributes for the input[@type=password] tag
        #
        # @return [String] The generated HTML input[@type=password] tag
        #
        # @example Basic usage
        #   password_field_tag(:snippet_name)
        #     #=> <input class="text" id="snippet_name" name="snippet_name" type="password">
        #
        # @example With a value
        #   password_field_tag(:snippet_name, value: 'some-value')
        #     #=>
        #       <input class="text" id="snippet" name="snippet" type="password" value="some-value">
        #
        # @example With custom `:id` attribute
        #   password_field_tag(:snippet_name, id: 'some-id')
        #     #=> <input class="text" id="some-id" name="snippet_name" type="password">
        #
        # @example Without the `:id` attribute
        #  NOTE! bad practice.
        #
        #   password_field_tag(:snippet_name, id: false)
        #     #=> <input class="text" name="snippet_name" type="password">
        #
        # @example Adding another CSS class
        #  NOTE! appends the the class to the default class `.text`.
        #
        #   password_field_tag(:snippet_name, class: :big )
        #     #=> <input class="big text" id="snippet_name" name="snippet_name" type="password">
        #
        # @example Adds a `:title` attribute when passed `:ui_hint`.
        #   password_field_tag(:name, ui_hint: 'a user hint')
        #     #=> <input class="text" id="name" name="name" title="a user hint" type="password">
        #
        # @example Supports `:maxlength`, `:size` & `:disabled` attributes
        #   password_field_tag(:ip, maxlength: 15, size: 20)
        #     #=> <input class="text" id="ip" maxlength="15" name="ip" size="20" type="password">
        #
        #   password_field_tag(:name, disabled: true)
        #     #=> <input class="text" id="name" disabled="disabled" name="name" type="password">
        #
        def password_field_tag(name, attrs = {})
          attrs.reverse_merge!(name: name, type: :password)
          attrs = add_css_id(attrs, name)
          attrs = add_css_class(attrs, :text) # deliberately giving it the .text class
          attrs = add_ui_hint(attrs)
          tag(:input, attrs)
        end
        alias passwordfield_tag password_field_tag

        # Creates a file upload field. If you are using file uploads then you will also
        # need to set the multipart option for the form tag:
        #
        #   <% form_tag '/upload', :multipart => true do %>
        #     <label for="file">File to Upload</label>
        #     <%= file_field_tag 'file' %>
        #     <%= submit_tag %>
        #   <% end %>
        #
        # The specified URL will then be passed a File object containing the selected file,
        # or if the field was left blank, a StringIO object.
        #
        # @param name [String] The field name used for :id & :name attributes
        # @param attrs [Hash] HTML attributes for the input[@type=file] tag
        #
        # @return [String] The generated HTML input[@type=file] tag
        #
        # @example Basic usage
        #   file_field_tag('attachment')
        #     #=> <input class="file" id="attachment" name="attachment" type="file">
        #
        # @example Ignores the invalid `:value` attribute.
        #   file_field_tag(:photo, value: 'some-value')
        #     #=> <input class="file" id="photo" name="photo" type="file">
        #
        # @example Setting a different `:id`
        #   file_field_tag(:photo, id: 'some-id')
        #     #=> <input class="file" id="some-id" name="photo" type="file">
        #
        # @example Removing the `:id` attribute completely
        #  NOTE! bad practice.
        #
        #   file_field_tag(:photo, id: false)
        #     #=> <input class="file" name="photo" type="file">
        #
        # @example Adding another CSS class.
        #  NOTE! appends the the class to the default class +.text+.
        #
        #   file_field_tag(:photo, class: :big )
        #     #=> <input class="big file" id="photo" name="photo" type="file">
        #
        # @example Adds a `:title` attribute when passed `:ui_hint`. Also works with +:title+.
        #   file_field_tag(:photo, ui_hint: 'a user hint')
        #     #=> <input class="file" id="photo" name="photo" title="a user hint" type="file">
        #
        # @example Supports the `:disabled` attribute.
        #   file_field_tag(:photo, disabled: true)
        #     #=> <input class="file" disabled="disabled" id="photo" name="photo" type="file">
        #
        # @example Supports the `:accept` attribute, even though most browsers don't.
        #   file_field_tag(:photo, accept: 'image/png,image/jpeg')
        #     #=>  <input accept="image/png,image/jpeg" class="file" ... type="file">
        #
        def file_field_tag(name, attrs = {})
          attrs.reverse_merge!(name: name, type: :file)
          attrs.delete(:value) # can't use value, so delete it if present
          attrs = add_css_id(attrs, name)
          attrs = add_css_class(attrs, :file)
          attrs = add_ui_hint(attrs)
          tag(:input, attrs)
        end
        alias filefield_tag file_field_tag

        # Constructs a textarea input from the given options
        #
        # * `:escape` - By default, the contents of the text input are HTML escaped. If you
        #   need unescaped contents, set this to false.
        #
        # Any other key creates standard HTML attributes for the tag.
        #
        # @param name [String] The field name used for :id & :name attributes
        # @param attrs [Hash] HTML attributes for the textarea tag
        #
        # @return [String] The generated HTML textarea tag
        #
        # TODO: enable :escape functionality...
        #
        # @example Basic usage
        #   textarea_tag('post')
        #     #=> <textarea id="post" name="post">\n</textarea>
        #
        # @example Providing a value:
        #   textarea_tag(:bio, value: @actor.bio)
        #     #=> <textarea id="bio" name="bio">This is my biography.\n</textarea>
        #
        # @example Setting a different `:id`
        #   textarea_tag(:body, id: 'some-id')
        #     #=> <textarea id="some-id" name="post">\n\n</textarea>
        #
        # @example Adding a CSS class.
        # NOTE! textarea has no other class by default.
        #
        #   textarea_tag(:body, class: 'big')
        #     #=> <textarea class="big" id="post" name="post">\n</textarea>
        #
        # @example Adds a `:title` attribute when passed `:ui_hint`.
        #   textarea_tag(:body, ui_hint: 'a user hint')
        #     #=> <textarea id="post" name="post" title="a user hint">\n</textarea>
        #
        # @example Supports `:rows` & `:cols` attributes.
        #   textarea_tag('body', rows: 10, cols: 25)
        #     #=> <textarea cols="25" id="body" name="body" rows="10">\n</textarea>
        #
        # @example Supports shortcut to `:rows` & `:cols` attributes, via the `:size` attribute.
        #   textarea_tag( 'body', size: "25x10")
        #     #=> <textarea cols="25" id="body" name="body" rows="10"></textarea>
        #
        # @example Supports `:disabled` & `:readonly` attributes.
        #   textarea_tag(:description, disabled: true)
        #     #=> <textarea disabled="disabled" id="description" name="description"></textarea>
        #
        #   textarea_tag(:description, readonly: true)
        #     #=> <textarea id="description" name="description" readonly="readonly"></textarea>
        #
        def textarea_tag(name, attrs = {})
          attrs.reverse_merge!(name: name)
          attrs = add_css_id(attrs, name)
          if size = attrs.delete(:size)
            attrs[:cols], attrs[:rows] = size.split('x') if size.respond_to?(:split)
          end

          # TODO: add sanitation support of the value passed
          # content = Rack::Utils.escape_html(attrs.delete(:value).to_s)
          content = attrs.delete(:value).to_s
          attrs   = add_ui_hint(attrs)
          tag(:textarea, content, attrs)
        end
        alias text_area_tag textarea_tag

        # Creates a fieldset tag wrapping the provided content
        #
        # @param args [Array] Arguments - first arg can be legend text or last arg can be attrs hash
        # @param attrs [Hash] Optional HTML attributes hash if last arg is a hash
        # @yield Optional block containing fieldset content
        # @yieldreturn [String] The captured HTML content for the fieldset
        #
        # @return [String] The generated HTML fieldset with legend and content
        #
        # @example Basic usage with legend text
        #   fieldset_tag("User Details")
        #     #=> <fieldset id="fieldset-user-details">
        #     #     <legend>User Details</legend>
        #     #   </fieldset>
        #
        # @example With attributes and block content
        #   fieldset_tag("Details", class: "form-section") do
        #     text_field_tag(:name)
        #   end
        #     #=> <fieldset class="form-section" id="fieldset-details">
        #     #     <legend>Details</legend>
        #     #     <input type="text" name="name" id="name">
        #     #   </fieldset>
        #
        # @example With legend in attributes
        #   fieldset_tag(legend: "Section", class: "bordered")
        #     #=> <fieldset class="bordered" id="fieldset">
        #     #     <legend>Section</legend>
        #     #   </fieldset>
        #
        # @example Sets the `<legend>` and `:id` attribute when given a single argument.
        #   <% fieldset_tag 'User Details' do %>
        #     <p><%= textfield_tag 'name' %></p>
        #   <% end %>
        #     #=> <fieldset id="fieldset-user-details">
        #     #     <legend>User Details</legend>
        #     #     <p><input name="name" class="text" id="name" type="text"></p>
        #     #   </fieldset>
        #
        # @example Supports `:legend` attribute for the `<legend>` tag.
        #   fieldset_tag(:actor, legend: 'Your Details')
        #     #=> <fieldset id="fieldset-actor">
        #     #      <legend>Your Details</legend>
        #     #      <snip...>
        #
        # @example Adding a CSS class.
        #
        # NOTE! fieldset has no other class by default.
        #
        #   fieldset_tag(:actor, class: "legend-class")
        #     #=> <fieldset class="legend-class" id="fieldset-actor">
        #     #     <snip...>
        #
        # @example When passed +nil+ as the first argument the `:id` becomes 'fieldset'.
        #   fieldset_tag(nil, class: 'format')
        #     #=> <fieldset class="format" id="fieldset">
        #     #     <snip...>
        #
        # @example Removing the `:id` attribute completely.
        #   fieldset_tag('User Details', id: false)
        #     #=> <fieldset>
        #     #      <legend>User Details</legend>
        #     #      <snip...>
        #
        # rubocop:disable Metrics/AbcSize
        def fieldset_tag(*args, &block)
          attrs = args.last.is_a?(Hash) ? args.pop : {}
          attrs = add_css_id(attrs, ['fieldset', args.first].compact.join('-'))

          legend_text = args.first.is_a?(String || Symbol) ? args.first : attrs.delete(:legend)
          legend_html = legend_text.blank? ? '' : tag(:legend, legend_text)
          captured_html = block_given? ? capture_html(&block) : ''
          concat_content(tag(:fieldset, legend_html + captured_html, attrs))
        end
        # rubocop:enable Metrics/AbcSize
        alias field_set_tag fieldset_tag

        # Creates a legend tag with given contents and attributes
        #
        # @param contents [String] The text content for the legend
        # @param attrs [Hash] HTML attributes for the legend tag
        #
        # @return [String] The generated HTML legend tag
        #
        # @example Basic usage
        #   legend_tag('User Details')
        #     #=> <legend>User Details</legend>
        #
        # @example With id attribute
        #   legend_tag('User Details', id: 'user-legend')
        #     #=> <legend id="user-legend">User Details</legend>
        #
        # @example With CSS class
        #   legend_tag('User Details', class: 'form-legend')
        #     #=> <legend class="form-legend">User Details</legend>
        #
        def legend_tag(contents, attrs = {})
          tag(:legend, contents, attrs)
        end

        # Creates a checkbox element.
        #
        # @param name [String] The field name used for :id & :name attributes
        # @param attrs [Hash] HTML attributes for the input[@type=checkbox] tag
        #
        # @return [String] The generated HTML input[@type=checkbox] tag
        #
        # @example Basic usage
        #   check_box_tag(:accept)
        #     #=> <input class="checkbox" id="accept" name="accept" type="checkbox" value="1">
        #
        # @example Providing a value:
        #   check_box_tag(:rock, value: 'rock music')
        #     #=> <input class="checkbox" id="rock" name="rock" type="checkbox" value="rock music">
        #
        # @example Setting a different `:id`.
        #   check_box_tag(:rock, :id => 'some-id')
        #     #=> <input class="checkbox" id="some-id" name="rock" type="checkbox" value="1">
        #
        # @example Adding another CSS class.
        #  NOTE! appends the the class to the default class `.checkbox`.
        #
        #   check_box_tag(:rock, class: 'small')
        #     #=> <input class="small checkbox" id="rock" name="rock" type="checkbox" value="1">
        #
        # @example Adds a `:title` attribute when passed `:ui_hint`.
        #   check_box_tag(:rock, ui_hint: 'a user hint')
        #     #=> <input ... title="a user hint" type="checkbox" value="1">
        #
        # @example Supports the `:disabled` & `:checked` attributes.
        #   check_box_tag(:rock, checked: true)
        #     #=> <input checked="checked" ... type="checkbox" value="1">
        #
        #   check_box_tag(:rock, disabled: true)
        #     #=> <input class="checkbox" disabled="disabled" ... type="checkbox" value="1">
        #
        def check_box_tag(name, attrs = {})
          attrs.reverse_merge!(name: name, type: :checkbox, checked: false, value: 1)
          attrs = add_css_id(attrs, name)
          attrs = add_css_class(attrs, :checkbox)
          attrs = add_ui_hint(attrs)
          tag(:input, attrs)
        end
        alias checkbox_tag check_box_tag

        # Creates a radio button; use groups of radio buttons named the same to allow users to
        # select from a group of options.
        #
        # @param name [String] The field name used for :id & :name attributes
        # @param attrs [Hash] HTML attributes for the input[@type=radio] tag
        #
        # @return [String] The generated HTML input[@type=radio] tag
        #
        # @example Basic usage
        #   radio_button_tag(:accept)
        #     #=> <input class="radio" id="accept_1" name="accept" type="radio" value="1">
        #
        # @example Providing a value:
        #   radio_button_tag(:rock, value: 'rock music')
        #     #=> <input ... type="radio" value="rock music">
        #
        # @example Setting a different `:id`.
        #   radio_button_tag(:rock, id: 'some-id')
        #     #=> <input class="radio" id="some-id_1" name="rock" type="radio" value="1">
        #
        # @example Adding another CSS class
        #  NOTE! appends the the class to the default class +.radio+.
        #
        #   radio_button_tag(:rock, class: 'big')
        #     #=> <input class="big radio" id="rock_1" name="rock" type="radio" value="1">
        #
        # @example Adds a `:title` attribute when passed `:ui_hint`.
        #   radio_button_tag(:rock, ui_hint: 'a user hint')
        #     #=> <input ... title="a user hint" type="radio" value="1">
        #
        # @example Supports the `:disabled` & `:checked` attributes.
        #   radio_button_tag(:yes, checked: true)
        #     #=> <input checked="checked" class="checkbox" id="yes_1"...value="1">
        #
        #   radio_button_tag(:yes, disabled: true)
        #     #=> <input disabled="disabled" class="checkbox" id="yes_1" ... value="1">
        #
        def radio_button_tag(name, attrs = {})
          attrs.reverse_merge!(name: name, type: :radio, checked: false, value: 1)
          attrs = add_css_id(attrs, name)
          # id_value = [field.to_s,'_',value].join
          attrs[:id] = [attrs[:id], html_safe_id(attrs[:value])].compact.join('_')
          attrs = add_css_class(attrs, :radio)
          attrs = add_ui_hint(attrs)
          tag(:input, attrs)
        end
        alias radiobutton_tag radio_button_tag

        # Creates a submit button with the text value as the caption.
        #
        # @param name [String] The field name used for :id & :name attributes
        # @param attrs [Hash] HTML attributes for the input[@type=submit] tag
        #
        # @return [String] The generated HTML input[@type=submit] tag
        #
        # @example Basic usage
        #   <%= submit_tag %> || <%= submit_button %>
        #     => <input name="submit" type="submit" value="Save Form">
        #
        #   <%= submit_tag(nil) %>
        #     => <input name="submit" type="submit" value="">
        #
        #   <%= submit_tag("Custom Value") %>
        #     => <input name="submit" type="submit" value="Custom Value">
        #
        # @example Adding a CSS class.
        #  NOTE! input[:submit] has no other class by default.
        #
        #   <%= submit_tag(class: 'some-class') %>
        #     #=> <input class="some-class" name="submit" type="submit" value="Save Form">
        #
        # @example Supports the `:disabled` attribute.
        #   <%= submit_tag(disabled: true) %>
        #     #=> <input disabled="disabled" name="submit" type="submit" value="Save Form">
        #
        # @example Adds a `:title` attribute when passed `:ui_hint`. Also works with `:title`.
        #   <%= submit_tag(ui_hint: 'a user hint') %>
        #     #=> <input name="submit" title="a user hint" type="submit" value="Save Form">
        #
        def submit_tag(value = 'Save Form', attrs = {})
          if value.is_a?(Hash)
            attrs = value
            value = 'Save Form'
          end
          attrs.reverse_merge!(type: :submit, name: :submit, value: value)
          attrs = add_ui_hint(attrs)
          self_closing_tag(:input, attrs)
        end
        alias submit_button submit_tag

        # Creates a image submit button which submits the form when clicked.
        #
        # @param src [String] The URL/path to the image
        # @param attrs [Hash] HTML attributes for the input[@type=image] tag
        #
        # @return [String] The generated HTML input[@type=image] tag
        #
        # @example Basic usage
        #   image_submit_tag('/images/submit.png')
        #     #=> <input src="/images/submit.png" type="image">
        #
        # @example With attributes
        #   image_submit_tag('/images/submit.png', class: 'submit-button')
        #     #=> <input class="submit-button" src="/images/submit.png" type="image">
        #
        # @example With disabled state
        #   image_submit_tag('/images/submit.png', disabled: true)
        #     #=> <input disabled="disabled" src="/images/submit.png" type="image">
        #
        def image_submit_tag(src, attrs = {})
          tag(:input, { type: :image, src: src }.merge(attrs))
        end
        alias imagesubmit_tag image_submit_tag

        # Creates a reset button with the text value as the caption.
        #
        # @param value [String] The button text
        # @param attrs [Hash] HTML attributes for the input[@type=reset] tag
        #
        # @return [String] The generated HTML input[@type=reset] tag
        #
        # @example Basic usage
        #   <%= reset_tag %>
        #     => <input name="reset" type="reset" value="Reset Form">
        #
        #   <%= reset_tag(nil) %>
        #     => <input name="reset" type="reset" value="">
        #
        # @example Adding a CSS class
        #  NOTE! input[:reset] has no other class by default.
        #
        #   <%= reset_tag('Custom Value', class: 'some-class') %>
        #     => <input class="some-class" name="reset" type="reset" value="Custom Value" >
        #
        # @example Supports the `:disabled` attribute.
        #   <%= reset_tag('Custom Value', disabled: true) %>
        #     => <input disabled="disabled" name="reset" type="reset" value="Custom Value">
        #
        # @example Adds a `:title` attribute when passed `:ui_hint`.
        #   <%= reset_tag('Custom Value', ui_hint: 'a user hint') %>
        #     => <input name="reset" title="a user hint" type="reset" value="Custom Value">
        #
        def reset_tag(value = 'Reset Form', attrs = {})
          if value.is_a?(Hash)
            attrs = value
            value = 'Reset Form'
          end
          attrs.reverse_merge!(type: :reset, name: :reset, value: value)
          attrs = add_ui_hint(attrs)
          self_closing_tag(:input, attrs)
        end
        alias reset_button reset_tag

        # Creates a select (dropdown menu) form element with options
        # Automatically handles single vs multiple selection modes
        #
        # @param name [String, Symbol] The name/id for the select element
        # @param options [Array, Hash] The options to populate the dropdown
        #   Can be array of [value, text] pairs or hash of value => text mappings
        # @param attrs [Hash] HTML attributes to apply to the select element
        #   Special options include:
        #   - :selected => Value(s) to mark as selected
        #   - :multiple => Allow multiple selections
        #   - :prompt => Add placeholder prompt option
        #
        # NOTE! the format for the options values must be [value, key].
        #
        # @return [String] The generated HTML select element with options
        #
        # @example Basic dropdown with array options
        #   select_tag(:color, [['red', 'Red'], ['blue', 'Blue']])
        #     #=> <select id="color" name="color">
        #     #     <option value="red">Red</option>
        #     #     <option value="blue">Blue</option>
        #     #   </select>
        #
        # @example Multiple select with hash options
        #
        # NOTE! the [] on the `:name` attribute
        #
        #   select_tag(:colors, {red: 'Red', blue: 'Blue'}, multiple: true)
        #     #=> <select id="colors" name="colors[]" multiple="multiple">
        #     #     <option value="red">Red</option>
        #     #     <option value="blue">Blue</option>
        #     #     <snip...>
        #
        # @example With Selected Option value
        #   select_tag(:letters, @letters, selected: :a)
        #     #=> <select id="letters" name="letters">
        #     #     <option selected="selected" value="a">A</option>
        #     #     <snip...>
        #
        # @example With Multiple Selected Options Array
        #
        # NOTE! the [] on the `:name` attribute and the select menu automatically
        # becomes a multiple select box.
        #
        #   select_tag(:letters, @letters, selected: [:a,'b'])
        #     #=> <select id="letters" multiple="multiple" name="letters[]">
        #     #     <option selected="selected" value="a">A</option>
        #     #     <option selected="selected" value="b">B</option>
        #     #     <snip...>
        #
        # @example With custom `:id` attribute
        #   select_tag(:letters, @letters, id: 'my-letters')
        #     #=> <select id="my-letters" name="letters">
        #     #     <snip...>
        #
        # @example With custom `:class` attribute
        #   select_tag(:letters, @letters, class: 'funky-select')
        #     #=> <select class="funky-select" id="my-letters" name="letters">
        #     #     <snip...>
        #
        # @example With `prompt: true` attribute
        #   select_tag(:letters, @letters, prompt: true)
        #     #=> <select id="letters" name="letters">
        #     #     <option selected="selected" value="">- Select -</option>
        #     #     <snip...>
        #
        # @example With `prompt: 'Custom'` attribute
        #   select_tag(:letters, @letters, prompt: 'Top Letters')
        #     #=> <select id="letters" name="letters">
        #     #     <option value="">Top Letters</option>
        #     #     <snip...>

        # @example With `disabled: true` attribute
        #   select_tag(:letters, @letters, disabled: true)
        #     #=> <select id="letters" disabled="disabled" name="letters">
        #     #     <snip...>
        #
        def select_tag(name, options, attrs = {})
          options = options.to_a.reverse if options.is_a?(Hash)
          attrs[:multiple] = true if attrs[:selected].is_a?(Array)
          options_html = select_options(options, attrs)
          attrs.delete(:selected)
          # attrs = add_css_id(attrs, name)
          add_css_id(attrs, name)

          html_name = attrs[:multiple] == true && !name.to_s.end_with?('[]') ? "#{name}[]" : name

          tag(:select, options_html, { name: html_name }.merge(attrs))
        end

        # Creates an option tag for use in a select dropdown menu.
        #
        # @param value [String] The value attribute for the option
        # @param key [String] The text content shown to the user
        # @param attrs [Hash] Additional HTML attributes for the option tag
        #
        # @return [String] The generated HTML option tag
        #
        # @example Basic usage
        #   select_option('a', 'Letter A')
        #     #=> <option value="a">Letter A</option>
        #
        # @example When key is blank, titleizes value
        #   select_option('on', '')
        #     #=> <option value="on">On</option>
        #
        # @example With selected attribute
        #   select_option('a', 'Letter A', selected: true)
        #     #=> <option selected="selected" value="a">Letter A</option>
        #
        def select_option(value, key, attrs = {})
          key = value.to_s.titleize if key.blank?
          tag(:option, key, { value: value }.merge(attrs))
        end

        # Creates a hidden input field for HTTP method override support (e.g. PUT/DELETE requests)
        # Used internally by form_tag for non-GET/POST methods.
        # Supports `Rack::MethodOverride`
        #
        # @param method [String] The HTTP method to override with (default: 'PUT')
        # @return [String] Hidden input field with _method override
        #
        # @example Basic usage
        #   faux_method('DELETE')
        #     #=> <input name="_method" type="hidden" value="DELETE">
        #
        # @example Default PUT method
        #   faux_method
        #     #=> <input name="_method" type="hidden" value="PUT">
        #
        def faux_method(method = 'PUT')
          hidden_field_tag(:input, name: '_method', value: method.to_s.upcase)
        end

        private

        # Returns the tag helper options hash from Roda options.
        # These options control default HTML attributes and formatting for generated tags.
        #
        # @return [Hash] The tag helper configuration options
        #
        # @example Basic usage
        #   opts_tag_helpers[:tags_label_required_str]
        #     #=> '<span>*</span>'
        #
        def opts_tag_helpers
          opts[:tag_helpers]
        end

        # Converts a string to an HTML safe ID attribute value
        # - Converts to lowercase
        # - Replaces non-word characters with hyphens
        # - Collapses multiple hyphens into single hyphens
        #
        # @param id [String, #to_s] The value to convert to an HTML safe ID
        #
        # @return [String] The sanitized ID value
        #
        # @example Basic usage
        #   html_safe_id("Hello World!")
        #     #=> "hello-world-"
        #
        # @example With symbols
        #   html_safe_id(:hello_world)
        #     #=> "hello-world"
        #
        # @example Collapsing multiple hyphens
        #   html_safe_id("too--many---hyphens")
        #     #=> "too-many-hyphens"
        #
        def html_safe_id(id)
          id.to_s.downcase.gsub(/\W/, '-').gsub('--', '-')
        end

        # Adds CSS classes to the HTML attributes hash.
        # Merges new classes with any existing classes, preserving existing ones.
        #
        # @param attrs [Hash] HTML attributes hash
        # @param new_class [String, Symbol, nil] Additional CSS class(es) to add
        #
        # @return [Hash] Updated attributes hash with merged classes
        #
        # @example Basic usage
        #   add_css_class({}, 'btn')
        #     #=> { class: 'btn' }
        #
        # @example With existing classes
        #   add_css_class({class: 'red'}, 'btn')
        #     #=> { class: 'red btn' }
        #
        # @example With nil new_class
        #   add_css_class({class: 'red'}, nil)
        #     #=> { class: 'red' }
        #
        def add_css_class(attrs, new_class = nil)
          merge_attr_classes(attrs, new_class)
        end

        # Adds or updates the ID attribute in the HTML attributes hash.
        # Handles nil/empty values and sanitizes the ID for HTML safety.
        #
        # @param attrs [Hash, nil] HTML attributes hash to modify
        # @param new_id [String, Symbol, Hash] New ID value to set
        #
        # @return [Hash] Updated attributes hash with ID added/modified
        #
        # @example Basic usage
        #   add_css_id({}, 'my-id')
        #     #=> { id: 'my-id' }
        #
        # @example With existing ID
        #   add_css_id({id: 'old'}, 'new')
        #     #=> { id: 'old' }
        #
        # @example With false ID
        #   add_css_id({}, false)
        #     #=> {} # No ID added
        #
        # @example With empty ID
        #   add_css_id({}, '')
        #     #=> {} # ID removed
        #
        def add_css_id(attrs, new_id)
          attrs = {} if attrs.nil?
          new_id = '' if new_id.is_a?(Hash)
          id_value = attrs[:id].nil? ? html_safe_id(new_id.to_s) : attrs.delete(:id)
          attrs[:id] = id_value.to_s unless id_value == false
          attrs[:id] = nil if attrs[:id] == '' # set to nil to remove from tag output
          attrs
        end

        # Adds a title attribute to HTML elements based on ui_hint option
        # Moves the :ui_hint value to :title if present
        #
        # @param attrs [Hash] HTML attributes hash
        #
        # @return [Hash] Updated attributes hash with ui_hint moved to title
        #
        # @example Basic usage
        #   add_ui_hint({ui_hint: 'Help text'})
        #     #=> {title: 'Help text'}
        #
        # @example With no ui_hint
        #   add_ui_hint({class: 'btn'})
        #     #=> {class: 'btn'}
        #
        def add_ui_hint(attrs)
          attrs[:title] = attrs.delete(:ui_hint) unless attrs[:ui_hint].nil?
          attrs
        end

        # Creates and returns select option elements from an array of values or hash
        # Handles optgroups, selected values, and prompts
        #
        # @param values [Array, Hash] The values to create options from. Can be:
        #   - Array of [value, text] pairs: `[["a", "Option A"], ["b", "Option B"]]`
        #   - Hash of value => text pairs: `{"a" => "Option A", "b" => "Option B"}`
        #   - Nested hash for optgroups: `{"Group 1" => {"a" => "Option A"}}`
        # @param attrs [Hash] HTML attributes hash containing selection options
        # @option attrs [String, Array] :selected Value(s) to mark as selected
        # @option attrs [String, true] :prompt Optional prompt text or true for default
        #
        # @return [String] Generated HTML option tags
        #
        # @example Basic array of options
        #   select_options([["a", "Option A"], ["b", "Option B"]])
        #     #=>  <option value="a">Option A</option>
        #     #    <option value="b">Option B</option>
        #
        # @example With selected value
        #   select_options([["a", "A"], ["b", "B"]], selected: "a")
        #     #=> <option value="a" selected="selected">A</option>
        #     #   <option value="b">B</option>
        #
        # @example With optgroups
        #   select_options({ 'Group 1' => {:a => 'A' }, 'Group 2' => { 'b' => 'B' } })
        #     #=> <optgroup label="Group 1">
        #     #     <option value="a">A</option>
        #     #   </optgroup>
        #     #   <optgroup label="Group 2">
        #     #     <option value="b">B</option>
        #     #   </optgroup>
        #
        # rubocop:disable Metrics/MethodLength
        def select_options(values, attrs = {})
          attrs = {} if attrs.blank?
          values = [] if values.blank?
          normalize_select_prompt(values, attrs)
          # { :a => 'A' }
          # [5, 'E']
          #  FIXME:: when passed a Hash of values, they become reversed (last first and so on..)

          values.map do |value, key|
            if value.is_a?(Hash)
              tag(:optgroup, select_options(value, attrs), label: key)
            elsif option_selected?(value, attrs[:selected])
              select_option(value, key, selected: true)
            else
              select_option(value, key)
            end
          end.join
        end
        # rubocop:enable Metrics/MethodLength

        # Normalizes the prompt option for select dropdowns
        # - Removes prompt from attributes after processing
        # - Sets blank option as selected by default unless explicit selection
        # - Uses default "- Select -" text if prompt is true
        # - Adds prompt as first empty option in values array
        #
        # @param values [Array] Array of select options to prepend prompt to
        # @param attrs [Hash] Attributes hash containing prompt option
        #
        # @example With true prompt
        #   normalize_select_prompt(values, prompt: true)
        #   # Adds ["", "- Select -"] as first option
        #
        # @example With custom prompt text
        #   normalize_select_prompt(values, prompt: "Choose one")
        #   # Adds ["", "Choose one"] as first option
        #
        def normalize_select_prompt(values, attrs = {})
          return unless attrs.key?(:prompt)

          prompt = attrs.delete(:prompt)
          attrs[:selected] = '' unless attrs.include?(:selected)
          prompt_text = prompt == true ? '- Select -' : prompt
          values.unshift(['', prompt_text])
        end

        # Checks if a select option value should be marked as selected
        #
        # @param key [String, Symbol] The option value to check
        # @param selection [String, Symbol, Array] The currently selected value(s)
        #
        # @return [Boolean] true if option should be selected, false otherwise
        #
        # @example With single selection
        #   option_selected?('a', 'a') #=> true
        #   option_selected?('a', 'b') #=> false
        #
        # @example With array of selections
        #   option_selected?('a', ['a', 'b']) #=> true
        #   option_selected?('c', ['a', 'b']) #=> false
        #
        def option_selected?(key, selection)
          if selection.is_a?(Array)
            selection.map(&:to_s).include?(key.to_s)
          else
            selection.to_s == key.to_s
          end
        end
      end
      # rubocop:enable Metrics/ModuleLength
      # /InstanceMethods
    end
    # /RodaTagHelpers

    register_plugin(:tag_helpers, RodaTagHelpers)
  end
  # /RodaPlugins
end
