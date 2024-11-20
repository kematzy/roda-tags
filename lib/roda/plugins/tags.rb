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
        # Return the uitags options for this class.
        def tags_opts
          opts[:tags]
        end
      end

      # add module documentation
      # rubocop:disable Metrics/ModuleLength
      module InstanceMethods
        # Returns markup for tag _name_. 
        # 
        # Optionally _contents_ may be passed, which is literal content for spanning tags such as 
        # <tt>textarea</tt>, etc. 
        # 
        # A hash of _attrs_ may be passed as the *second* or *third* argument.
        #
        # Self closing tags such as <tt><br/></tt>, <tt><input/></tt>, etc are automatically closed 
        # depending on output format, HTML vs XHTML.
        # 
        # Boolean attributes like "<tt>selected</tt>", "<tt>checked</tt>" etc, are mirrored or 
        # removed when <tt>true</tt> or <tt>false</tt>.
        # 
        # ==== Examples
        #
        # Self closing tags:
        # 
        #   tag(:br)
        #   # => <br> or <br/> if XHTML
        #
        #   tag(:hr, class: "space")
        #   # => <hr class="space">
        #
        # Multi line tags:
        # 
        #   tag(:div)
        #   # => <div></div>
        #
        #   tag(:div, 'content')
        #   # => <div>content</div>
        #
        #   tag(:div, 'content', id: 'comment')
        #   # => <div id="comment">content</div>
        #
        #   tag(:div, id: 'comment')  # NB! no content
        #   # => <div id="comment"></div>
        #
        # Single line tags:
        # 
        #   tag(:h1,'Header')
        #   # => <h1>Header</h1>
        # 
        #   tag(:abbr, 'WHO', :title => "World Health Organization")
        #   # => <abbr title="World Health Organization">WHO</abbr>
        # 
        # Working with blocks
        # 
        #   tag(:div) do
        #     tag(:p, 'Hello World')
        #   end
        #   # => <div><p>Hello World</p></div>
        # 
        #   <% tag(:div) do %>
        #     <p>Paragraph 1</p>
        #     <%= tag(:p, 'Paragraph 2') %>
        #     <p>Paragraph 3</p>
        #   <% end %>
        #   # => 
        #     <div>
        #       <p>Paragraph 1</p>
        #       <p>Paragraph 2</p>
        #       <p>Paragraph 3</p>
        #     </div>
        # 
        # 
        #   # NB! ignored tag contents if given a block
        #   <% tag(:div, 'ignored tag-content') do  %>
        #     <%= tag(:label, 'Comments:', for: :comments)  %>
        #     <%= tag(:textarea,'textarea contents', id: :comments) %>
        #   <% end  %>
        #   # => 
        #     <div>
        #       <label for="comments">Comments:</label>
        #       <textarea id="comments">
        #         textarea contents
        #       </textarea>
        #     </div>
        # 
        # 
        # 
        # Boolean attributes:
        # 
        #   tag(:input, type: :checkbox, checked: true)
        #   # => <input type="checkbox" checked="checked">
        # 
        #   tag(:option, 'Sinatra', value: "1", selected: true)
        #   # => <option value="1" selected>Sinatra</option>
        # 
        #   tag(:option, 'PHP', value: "0", selected: false)
        #   # => <option value="0">PHP</option>
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
        # Update the +:class+ entry in the +attr+ hash with the given +classes+ and returns +attr+.
        # 
        #   attr = { class: 'alert', id: :idval }
        #   
        #   merge_attr_classes(attr, 'alert-info')  #=> { class: 'alert alert-info', id: :idval }
        # 
        #   merge_attr_classes(attr, [:alert, 'alert-info']) 
        #     #=> { class: 'alert alert-info', id: :idval }
        # 
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        def merge_attr_classes(attr, *classes)
          attr[:class] = [] if attr[:class].blank?
          attr[:class] = merge_classes(attr[:class], *classes)
          attr[:class] = nil if attr[:class] == '' # set to nil to remove from tag output
          attr
        end
        # Return an alphabetized string that includes all given class values.
        # 
        # Handles a combination of arrays, strings & symbols being passed in.
        # 

        #   attr = { class: 'alert', id: :idval }
        #   merge_classes(attr[:class], ['alert', 'alert-info'])  #=> 'alert alert-info'
        #
        #   merge_classes(attr[:class], :text)  #=> 'alert text'
        # 
        #   merge_classes(attr[:class], [:text, :'alert-info'])  #=> 'alert alert-info text'
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

        # Captures the html from a block of template code for erb or haml
        # 
        # ==== Examples
        # 
        #   capture_html(&block) => "...html..."
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

        # Outputs the given text to the templates buffer directly.
        # 
        # ==== Examples
        # 
        #   concat_content("This will be output to the template buffer in erb or haml")
        # 
        def concat_content(text = '')
          if respond_to?(:is_haml?) && is_haml?
          elsif erb_buffer?
            buffer_concat(text)
          else # theres no template to concat, return the text directly
            text
          end
        end

        # Returns true if the block is from an ERB or HAML template; false otherwise.
        # Used to determine if html should be returned or concatenated to a view.
        # 
        # ==== Examples
        # 
        #   block_is_template?(block)
        # 
        def block_is_template?(block)
          block && (erb_block?(block) || (respond_to?(:block_is_haml?) && block_is_haml?(block)))
        end

        def output_is_xhtml?
          opts[:tags][:tag_output_format_is_xhtml]
        end

        private
        # Return an opening tag of _name_, with _attrs_.

        def open_tag(name, attrs = {})
          "<#{name}#{normalize_html_attributes(attrs)}>"
        end
        # Return closing tag of _name_.

        #
        def closing_tag(name)
          "</#{name}>#{add_newline?}"
        end
      
        # Creates a self closing tag.  Like <br/> or <img src="..."/>
        # 
        # ==== Options
        # +name+ : the name of the tag to create
        # +attrs+ : a hash where all members will be mapped to key="value"
        # 

        def self_closing_tag(name, attrs = {})
          newline = attrs[:newline].nil? ? nil : attrs.delete(:newline)
          "<#{name}#{normalize_html_attributes(attrs)}#{is_xhtml?}#{add_newline?(newline)}"
        end
        # Based upon the context, wraps the tag content in '\n' (newlines)
        #  
        # ==== Examples
        # 
        #   tag_contents_for(:div, 'content', nil)
        #   # => <div>content</div>
        # 
        #   tag_contents_for(:div, 'content', false)
        #   # => <div>content</div>
        # 
        # Single line tag
        #   tag_contents_for(:option, 'content', true)
        #   # => <option...>\ncontent\n</option>
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
        # Normalize _attrs_, replacing boolean keys with their mirrored values.

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
        # Check if _name_ is a boolean attribute.
        # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

        def boolean_attribute?(name)
          BOOLEAN_ATTRIBUTES.include?(name.to_s)
        end
        # Check if tag _name_ is a self-closing tag.

        def self_closing_tag?(name)
          SELF_CLOSING_TAGS.include?(name.to_s)
        end
        # Check if tag _name_ is a single line tag.

        #
        def single_line_tag?(name)
          SINGLE_LINE_TAGS.include?(name.to_s)
        end
        # Check if tag _name_ is a multi line tag.

        def multi_line_tag?(name)
          MULTI_LINE_TAGS.include?(name.to_s)
        end
      
        # Returns a '>' or ' />' string based on the output format used, ie: HTML vs XHTML
        def xhtml?
          opts[:tags][:tag_output_format_is_xhtml] ? ' />' : '>'
        end
        alias is_xhtml? xhtml?

        def add_newline?(add_override = nil)
          add = add_override.nil? ? opts[:tags][:tag_add_newlines_after_tags] : add_override
          add == true ? "\n" : ''
        end
        # concat contents to the buffer if present
        # 
        # ==== Examples
        # 
        #   buffer_concat("Direct to buffer")
        # 
        def buffer_concat(txt)
          @_out_buf << txt if buffer?
        end
        alias erb_concat buffer_concat

        # Used to capture the contents of html/ERB block
        # 
        # ==== Examples
        # 
        #   capture_block(&block) => '...html...'
        # 
        def capture_block(*args)
          with_output_buffer { block_given? && yield(*args) }
        end
        # Used to direct the buffer for the erb capture
        alias capture_erb capture_block

        def with_output_buffer(buf = '')
          old_buffer = @_out_buf
          @_out_buf = buf
          yield
          @_out_buf
        ensure
          @_out_buf = old_buffer
        end
        alias erb_with_output_buffer with_output_buffer

        # returns true if the buffer is not empty
        def buffer?
          !@_out_buf.nil?
        end
        alias have_buffer? buffer?
        alias erb_buffer? buffer?

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
