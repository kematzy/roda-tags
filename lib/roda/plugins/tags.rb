# frozen_string_literal: false

require 'roda'

require_relative '../../core_ext/hash'   unless {}.respond_to?(:to_html_attributes)
require_relative '../../core_ext/blank'  unless Object.new.respond_to?(:blank?)

class Roda
  # add module documentation
  module RodaPlugins
    # TODO: Add documentation here
    #
    #
    module RodaTags
      # default options
      OPTS = {
        # toggle for XHTML formatted output in case of legacy
        tag_output_format_is_xhtml: false,
        # toggle for adding newlines after output
        tag_add_newlines_after_tags: true
      }.freeze

      # Tags that should be rendered in multiple lines, like...
      #
      #   <body>
      #     <snip...>
      #   </body>
      #
      MULTI_LINE_TAGS = %w[
        a address applet bdo big blockquote body button caption center colgroup dd dir div dl dt
        fieldset form frameset head html iframe map noframes noscript object ol optgroup pre
        script section select small style table tbody td tfoot th thead title tr tt ul
      ].freeze

      # Self closing tags, like...
      #
      #   <hr> or <hr />
      #
      SELF_CLOSING_TAGS = %w[
        area base br col frame hr img input link meta param
      ].freeze

      # Tags that should be rendered in a single line, like...
      #
      #   <h1>Header</h1>
      #
      SINGLE_LINE_TAGS = %w[
        abbr acronym b cite code del dfn em h1 h2 h3 h4 h5 h6 i kbd
        label legend li option p q samp span strong sub sup var
      ].freeze

      # Boolean attributes, ie: attributes like...
      #
      #   <option value="a" selected="selected">A</option>
      #
      BOOLEAN_ATTRIBUTES = %w[
        autofocus checked disabled multiple readonly required selected
      ].freeze

      # Depend on the render plugin, since this plugin only makes
      # sense when the render plugin is used.
      def self.load_dependencies(app, _opts = OPTS)
        app.plugin :render
      end

      def self.configure(app, opts = {})
        opts = if app.opts[:tags]
                 app.opts[:tags][:orig_opts].merge(opts)
               else
                 OPTS.merge(opts)
               end

        app.opts[:tags]             = opts.dup
        app.opts[:tags][:orig_opts] = opts
      end

      # add module documentation
      module ClassMethods
        # Returns the tags options hash for the current Roda class instance.
        #
        # @example
        #   tags_opts
        #     #=> { tag_output_format_is_xhtml: false, tag_add_newlines_after_tags: true }
        #
        def tags_opts
          opts[:tags]
        end
      end

      # add module documentation
      # rubocop:disable Metrics/ModuleLength
      module InstanceMethods
        # Generates HTML tag markup based on the given name, content, and attributes
        #
        # @param name [String,Symbol] The tag name to generate (e.g. 'div', :span)
        # @param content [String,nil] Optional content for the tag (ignored if block given)
        # @param attrs [Hash] Optional HTML attributes hash that may include :newline toggle
        # @yield Optional block providing content for the tag
        #
        # @return [String] The generated HTML tag markup
        #
        # @example Basic tag
        #   tag(:div)  #=> <div></div>
        #
        # @example Tag with content
        #   tag(:p, "Hello")  #=> <p>Hello</p>
        #
        # @example Tag with attributes
        #   tag(:div, class: 'btn', id: 'submit')
        #     #=> <div class="btn" id="submit"></div>
        #
        # @example Self closing tags:
        #   tag(:br)  # => <br> / <br/>
        #
        #   tag(:hr, class: "space")  # => <hr class="space">
        #
        # @example Multi line tags:
        #   tag(:div, 'content')  # => <div>content</div>
        #
        #   tag(:div, 'content', id: 'comment')
        #     # => <div id="comment">content</div>
        #
        #   tag(:div, id: 'comment')  # NB! no content
        #     # => <div id="comment"></div>
        #
        # @example Single line tags:
        #   tag(:h1,'Header')
        #     # => <h1>Header</h1>
        #
        #   tag(:abbr, 'WHO', :title => "World Health Organization")
        #     # => <abbr title="World Health Organization">WHO</abbr>
        #
        # @example Tag with block
        #   tag(:div) { tag(:p, "Content") }  #=> "<div><p>Content</p></div>"
        #
        # @example Working with blocks
        #   tag(:div) do
        #     tag(:p, 'Hello World')
        #   end
        #     # => <div><p>Hello World</p></div>
        #
        #   <% tag(:div) do %>
        #     <p>Paragraph 1</p>
        #     <%= tag(:p, 'Paragraph 2') %>
        #     <p>Paragraph 3</p>
        #   <% end %>
        #     # => <div>
        #     #      <p>Paragraph 1</p>
        #     #      <p>Paragraph 2</p>
        #     #      <p>Paragraph 3</p>
        #     #    </div>
        #
        # NOTE! ignored tag contents if given a block
        #
        #   <% tag(:div, 'ignored tag-content') do  %>
        #     <%= tag(:label, 'Comments:', for: :comments)  %>
        #     <%= tag(:textarea,'textarea contents', id: :comments) %>
        #   <% end  %>
        #     # => <div>
        #     #      <label for="comments">Comments:</label>
        #     #      <textarea id="comments">
        #     #        textarea contents
        #     #      </textarea>
        #     #    </div>
        #
        # @example Boolean attributes
        #   tag(:input, type: :checkbox, checked: true)
        #     # => <input type="checkbox" checked="checked">
        #
        #   tag(:option, 'Sinatra', value: "1", selected: true)
        #     # => <option value="1" selected>Sinatra</option>
        #
        #   tag(:option, 'PHP', value: "0", selected: false)
        #     # => <option value="0">PHP</option>
        #
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def tag(*args, &block)
          name = args.first
          attrs = args.last.is_a?(Hash) ? args.pop : {}
          newline = attrs[:newline] # save before it gets tainted

          tag_content = block_given? ? capture_html(&block) : args[1] # content

          if self_closing_tag?(name)
            tag_html = self_closing_tag(name, attrs)
          else
            tag_html = "#{open_tag(name, attrs)}#{tag_contents_for(name, tag_content, newline)}"
            tag_html << closing_tag(name)
          end
          block_is_template?(block) ? concat_content(tag_html) : tag_html
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        # Updates the :class attribute in the given hash with additional class values.
        # Takes a hash and any number of class values as arguments.
        # Returns the modified hash with merged class values.
        #
        # @param attr [Hash] The attributes hash to modify
        # @param classes [Array<String,Symbol,Array>] Additional class values to merge
        #
        # @return [Hash] The modified attributes hash
        #
        # @example
        #   attr = { class: 'btn', id: 'submit' }
        #   merge_attr_classes(attr, 'primary', 'large')
        #     #=> { class: 'btn large primary', id: 'submit' }
        #
        #   attr = { id: 'submit' }
        #   merge_attr_classes(attr, ['btn', 'primary'])
        #     #=> { class: 'btn primary', id: 'submit' }
        #
        def merge_attr_classes(attr, *classes)
          attr[:class] = [] if attr[:class].blank?
          attr[:class] = merge_classes(attr[:class], *classes)
          attr[:class] = nil if attr[:class] == '' # set to nil to remove from tag output
          attr
        end

        # Merges class values from multiple sources into a single sorted string
        #
        # @param classes [Array<String,Symbol,Array>] Class values to merge, which can be:
        #   - Symbols: Converted directly to strings
        #   - Strings: Split on whitespace into multiple classes
        #   - Arrays: Each element converted to string
        #
        # @return [String] Space-separated string of unique, sorted class names
        #
        # @example Passing a hash
        #   attr = { class: 'alert', id: :idval }
        #   merge_classes(attr[:class], ['alert', 'alert-info'])  #=> 'alert alert-info'
        #
        #   merge_classes(attr[:class], :text)  #=> 'alert text'
        #
        # @example Passing a string, an array & symbol
        #   merge_classes('btn', ['primary', 'large'], :active)  #=> "active btn large primary"
        #
        # @example Passing a string & :symbol
        #   merge_classes('alert alert-info', :text)  #=> "alert alert-info text"
        #
        # rubocop:disable Metrics/AbcSize
        def merge_classes(*classes)
          klasses = []
          classes.each do |c|
            klasses << c.to_s if c.is_a?(Symbol)
            c.split(/\s+/).each { |x| klasses << x.to_s } if c.is_a?(String)
            c.each { |i| klasses << i.to_s } if c.is_a?(Array)
          end
          klasses.compact.uniq.sort.join(' ').strip
        end
        # rubocop:enable Metrics/AbcSize

        ## HELPERS

        # Captures the content of a block with proper buffer handling
        #
        # @param block [String, Proc] The block to capture, defaults to empty string
        #
        # @return The captured content from the block
        #
        # @example Capturing a block's content
        #   capture { tag(:div, "content") }  # => <div>content</div>
        #
        # @example Capturing with explicit block parameter
        #   capture(some_block) { yield }  # => captured block content
        #
        # rubocop:disable Metrics/MethodLength
        def capture(block = '') # :nodoc:
          buf_was = @output
          @output = if block.is_a?(Proc)
                      eval('@_out_buf', block.binding, __FILE__, __LINE__ - 1) || @output
                    else
                      block
                    end
          yield
          ret = @output
          @output = buf_was
          ret
        end
        # rubocop:enable Metrics/MethodLength

        # Captures the content of a template block for Haml or ERB templates,
        # returning the captured HTML
        #
        # @param args [Array] Arguments to pass to the block
        # @param block [Proc] The template block to capture
        #
        # @return [String] The captured HTML content
        #
        # @example Capturing Haml content
        #   capture_html { tag :div, "Content" }  # => <div>Content</div>
        #
        # @example Capturing ERB content
        #   capture_html { tag :p, "Content" }  # => <p>Content</p>\n
        #
        # @example Direct block yield
        #   capture_html { "Content" }  # => Content
        #
        def capture_html(*args, &block)
          if respond_to?(:is_haml?) && is_haml?
            block_is_haml?(block) ? capture_haml(*args, &block) : yield
          elsif erb_buffer?
            result_text = capture_block(*args, &block)
            result_text.present? ? result_text : (block_given? && yield(*args))
          else # theres no template to capture, invoke the block directly
            yield(*args)
          end
        end

        # Outputs the given text to the template buffer based on the template engine in use.
        # For Haml templates, uses `haml_concat`. For ERB templates, uses `buffer_concat`.
        # If no template engine is active, returns the text directly.
        #
        # @param text [String] The text to output, defaults to empty string
        #
        # @return [String] The text if no template engine is active
        #
        # @example With Haml template
        #   concat_content("Hello")  # => Outputs "Hello" to Haml buffer
        #
        # @example With ERB template
        #   concat_content("World")  # => Outputs "World" to ERB buffer
        #
        # @example With no template
        #   concat_content("Test")  # => Returns "Test" string
        #
        def concat_content(text = '')
          if respond_to?(:is_haml?) && is_haml?
          elsif erb_buffer?
            buffer_concat(text)
          else # theres no template to concat, return the text directly
            text
          end
        end

        # Returns true if the given block is from an ERB or HAML template
        #
        # @param block [Proc] The block to check
        #
        # @return [Boolean] true if block is from an ERB/HAML template, false otherwise
        #
        # @example
        #   # if block is from ERB template
        #   block_is_template?(some_block)  #=> true
        #
        #   # if block is from HAML template
        #   block_is_template?(some_block)  #=> true
        #
        #   block_is_template?(regular_block)  #=> false
        #
        def block_is_template?(block)
          block && (erb_block?(block) || (respond_to?(:block_is_haml?) && block_is_haml?(block)))
        end

        # Returns whether the current output format is XHTML based on tag configuration
        #
        # @return [Boolean] true if XHTML output is enabled, false for HTML output
        #
        # @example
        #   # if :tag_output_format_is_xhtml is true in config
        #   output_is_xhtml?  #=> true
        #
        #   # if :tag_output_format_is_xhtml is false in config
        #   output_is_xhtml?  #=> false
        #
        def output_is_xhtml?
          opts[:tags][:tag_output_format_is_xhtml]
        end

        private

        # Returns an opening HTML tag string with the given name and optional attributes
        #
        # @param name [String,Symbol] The tag name (e.g. 'div', :span)
        # @param attrs [Hash] Optional HTML attributes hash (e.g. {class: 'btn'})
        #
        # @return [String] The opening tag string (e.g. '<div class="btn">')
        #
        # @example Basic tag
        #   open_tag(:div)  #=> "<div>"
        #
        # @example Tag with attributes
        #   open_tag(:div, class: 'btn', id: 'submit')
        #     #=> <div class="btn" id="submit">
        #
        def open_tag(name, attrs = {})
          "<#{name}#{normalize_html_attributes(attrs)}>"
        end

        # Returns a closing HTML tag string for the given tag name
        #
        # @param name [String,Symbol] The tag name to close (e.g. 'div', :span)
        #
        # @return [String] The closing tag string with optional newline
        #
        # @example Basic closing tag
        #   closing_tag(:div)  #=> "</div>\n" # with newlines enabled
        #
        # @example Without newlines
        #   closing_tag(:span)  #=> "</span>" # with newlines disabled
        #
        def closing_tag(name)
          "</#{name}>#{add_newline?}"
        end

        # Creates a self-closing HTML tag with optional attributes and newlines
        #
        # @param name [String,Symbol] The tag name (e.g. 'br', :img)
        # @param attrs [Hash] Optional attrs hash including `{ newline: true } toggle
        #
        # @return [String] The self-closing tag string (e.g. '<br>' or '<br />' for XHTML)
        #
        # @example Basic self-closing tag
        #   self_closing_tag(:br)  #=> "<br>" / "<br />" in XHTML
        #
        # @example With attributes and newlines
        #   self_closing_tag(:img, src: 'test.jpg', newline: true)
        #     #=> '<img src="test.jpg">\n' / '<img src="test.jpg" />\n'
        #
        def self_closing_tag(name, attrs = {})
          newline = attrs[:newline].nil? ? nil : attrs.delete(:newline)
          "<#{name}#{normalize_html_attributes(attrs)}#{is_xhtml?}#{add_newline?(newline)}"
        end

        # Formats tag contents with appropriate newlines based on tag type and options
        #
        # @param name [String,Symbol] The tag name to check format rules against
        # @param content [String] The content to be wrapped in the tag
        # @param newline [Boolean,nil] Override flag for newline insertion, nil uses default
        #
        # @return [String] The formatted content with appropriate newlines
        #
        # @example Multi-line tag
        #   tag_contents_for(:div, 'content')  #=> "\ncontent\n"
        #
        # @example Single-line tag with newlines
        #   tag_contents_for(:span, 'text', true)  #=> "\ntext\n"
        #
        # @example Basic content
        #   tag_contents_for(:p, 'text')  #=> "text"
        #
        def tag_contents_for(name, content, newline = nil)
          if multi_line_tag?(name)
            "#{add_newline?(newline)}#{content}#{add_newline?(newline)}".gsub("\n\n", "\n")
          elsif single_line_tag?(name) && newline == true
            "#{add_newline?(newline)}#{content}#{add_newline?(newline)}"
          else
            content.to_s
          end
        end

        # Normalizes HTML attributes handling special cases like data-* attributes
        # and boolean attributes
        #
        # @param attrs [Hash] Hash of HTML attributes to normalize
        #
        # @return [String, nil] Normalized attributes string with leading space, nil if attrs empty
        #
        # @example Basic attributes
        #   normalize_html_attributes(class: 'btn', id: 'submit')  #=> ' class="btn" id="submit"'
        #
        # @example Data attributes
        #   normalize_html_attributes(data: { value: 123 })  #=> ' data-value="123"'
        #
        # @example Boolean attributes
        #   normalize_html_attributes(checked: true, disabled: false)  #=> ' checked="checked"'
        #
        # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        def normalize_html_attributes(attrs = {})
          return if attrs.blank?

          attrs.delete(:newline) # remove newline from attributes
          # look for data attrs
          if (value = attrs.delete(:data))
            # NB!! convert key to symbol for [].sort
            value.each { |k, v| attrs[:"data-#{k}"] = v }
          end
          attrs.each do |name, val|
            if boolean_attribute?(name)
              val == true ? attrs[name] = name : attrs.delete(name)
            end
          end
          attrs.empty? ? '' : " #{attrs.to_html_attributes}"
        end
        # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

        # Checks if the given attribute name is a boolean HTML attribute like checked, disabled, etc
        #
        # @param name [String,Symbol] The attribute name to check
        #
        # @return [Boolean] true if attribute is boolean, false otherwise
        #
        # @example Boolean attribute
        #   boolean_attribute?(:checked)  #=> true
        #
        # @example Regular attribute
        #   boolean_attribute?(:class)  #=> false
        #
        def boolean_attribute?(name)
          BOOLEAN_ATTRIBUTES.include?(name.to_s)
        end

        # Checks if the given tag name is a self-closing tag like <br>, <img>, etc
        #
        # @param name [String,Symbol] The tag name to check
        #
        # @return [Boolean] true if tag is self-closing, false otherwise
        #
        # @example Self-closing tag
        #   self_closing_tag?(:br)  #=> true
        #
        # @example Regular tag
        #   self_closing_tag?(:div)  #=> false
        #
        def self_closing_tag?(name)
          SELF_CLOSING_TAGS.include?(name.to_s)
        end

        # Checks if the given tag name is a single-line tag that should be rendered without newlines
        #
        # @param name [String,Symbol] The tag name to check
        #
        # @return [Boolean] true if tag should be rendered on a single line, false otherwise
        #
        # @example Single-line tag
        #   single_line_tag?(:span)  #=> true
        #
        # @example Multi-line tag
        #   single_line_tag?(:div)  #=> false
        #
        def single_line_tag?(name)
          SINGLE_LINE_TAGS.include?(name.to_s)
        end

        # Checks if the given tag name is a multi-line tag that should be rendered with newlines
        #
        # @param name [String,Symbol] The tag name to check
        #
        # @return [Boolean] true if tag should be rendered with multiple lines, false otherwise
        #
        # @example Multi-line tag
        #   multi_line_tag?(:div)  #=> true
        #
        # @example Single-line tag
        #   multi_line_tag?(:span)  #=> false
        #
        def multi_line_tag?(name)
          MULTI_LINE_TAGS.include?(name.to_s)
        end

        # Returns a string for closing self-closing tags based on HTML/XHTML format setting
        #
        # @return [String] Returns ' />' for XHTML format, '>' for HTML format
        #
        # @example With XHTML format
        #   # When tag_output_format_is_xhtml is true
        #   xhtml?  #=> ' />'
        #
        # @example With HTML format
        #   # When tag_output_format_is_xhtml is false
        #   xhtml?  #=> '>'
        #
        def xhtml?
          opts[:tags][:tag_output_format_is_xhtml] ? ' />' : '>'
        end
        alias is_xhtml? xhtml?

        # Determines whether to add a newline based on override flag or default configuration
        #
        # @param add_override [Boolean, nil] Optional flag to override default newline behavior
        #   - When nil: Uses configured :tag_add_newlines_after_tags setting
        #   - When true/false: Uses override value directly
        #
        # @return [String] Returns "\n" for true, empty string for false
        #
        # @example Using default configuration
        #   add_newline?  #=> "\n" # When tag_add_newlines_after_tags is true
        #
        # @example With override
        #   add_newline?(false)  #=> "" # Forces no newline
        #
        def add_newline?(add_override = nil)
          add = add_override.nil? ? opts[:tags][:tag_add_newlines_after_tags] : add_override
          add == true ? "\n" : ''
        end

        # Appends text to the ERB output buffer if one exists
        #
        # @param txt [String] The text to append to the buffer
        #
        # @return [String, nil] The appended text if buffer exists, nil otherwise
        #
        # @example With active buffer
        #   buffer_concat("Hello")  #=> "Hello" # Added to @_out_buf
        #
        # @example With no buffer
        #   buffer_concat("Hello")  #=> nil # No buffer to append to
        #
        def buffer_concat(txt)
          @_out_buf << txt if buffer?
        end
        alias erb_concat buffer_concat

        # Captures the contents of a given block by executing it with a temporary output buffer
        #
        # @param args [Array] Arguments to pass through to the yielded block
        # @yield [*args] The block to capture contents from
        #
        # @return [String] The captured contents of the block, or nil if no block given
        #
        # @example Basic capture
        #   capture_block { "<div>content</div>" }
        #     #=> "<div>content</div>"
        #
        # @example With arguments
        #   capture_block("arg1", "arg2") { |a,b| "#{a} #{b}" }
        #     #=> "arg1 arg2"
        #
        def capture_block(*args)
          with_output_buffer { block_given? && yield(*args) }
        end
        alias capture_erb capture_block

        # Temporarily swaps the output buffer with a new one during block execution
        #
        # @param buf [String] The new buffer to use temporarily, defaults to empty string
        # @yield The block to execute with the temporary buffer
        #
        # @return [String] The contents of the temporary buffer after block execution
        #
        # @example Using temporary buffer
        #   with_output_buffer { @_out_buf << "content" }  #=> "content"
        #
        # @example Restoring original buffer
        #   old_buf = @_out_buf
        #   with_output_buffer { "content" }
        #   @_out_buf == old_buf #=> true
        #
        def with_output_buffer(buf = '')
          old_buffer = @_out_buf
          @_out_buf = buf
          yield
          @_out_buf
        ensure
          @_out_buf = old_buffer
        end
        alias erb_with_output_buffer with_output_buffer

        # Checks if an output buffer exists for template rendering
        #
        # @return [Boolean] true if @_out_buf is not nil, false otherwise
        #
        # @example With active buffer
        #   buffer?  #=> true # when @_out_buf exists
        #
        # @example With no buffer
        #   buffer?  #=> false # when @_out_buf is nil
        #
        def buffer?
          !@_out_buf.nil?
        end
        alias have_buffer? buffer?
        alias erb_buffer? buffer?

        # Checks if the given block is from an ERB template
        #
        # @param block [Proc] The block to check
        #
        # @return [Boolean] true if block is from ERB template or buffer exists, false otherwise
        #
        # @example With ERB template block
        #   erb_block?(erb_block)  #=> true
        #
        # @example With regular block
        #   erb_block?(regular_block)  #=> false
        #
        def erb_block?(block)
          have_buffer? ||
            (block && eval('defined? __in_erb_template', block.binding, __FILE__, __LINE__ - 1))
        end
        alias is_erb_block? erb_block?
        alias is_erb_template? erb_block?
      end
      # rubocop:enable Metrics/ModuleLength
      # /InstanceMethods
    end
    # /RodaTags

    register_plugin(:tags, RodaTags)
  end
  # /RodaPlugins
end
