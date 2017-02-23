module PrototypeHelper
  CALLBACKS    = Set.new([ :create, :uninitialized, :loading, :loaded,
                    :interactive, :complete, :failure, :success ] +
                    (100..599).to_a)
  AJAX_OPTIONS = Set.new([ :before, :after, :condition, :url,
                    :asynchronous, :method, :insertion, :position,
                    :form, :with, :update, :script, :type ]).merge(CALLBACKS)

  def remote_function(options)
    javascript_options = options_for_ajax(options)

    update = ''
    if options[:update] && options[:update].is_a?(Hash)
      update  = []
      update << "success:'#{options[:update][:success]}'" if options[:update][:success]
      update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
      update  = '{' + update.join(',') + '}'
    elsif options[:update]
      update << "'#{options[:update]}'"
    end

    function = update.empty? ?
      "new Ajax.Request(" :
      "new Ajax.Updater(#{update}, "

    url_options = options[:url]
    function << "'#{ERB::Util.html_escape(escape_javascript(url_for(url_options)))}'"
    function << ", #{javascript_options})"

    function = "#{options[:before]}; #{function}" if options[:before]
    function = "#{function}; #{options[:after]}"  if options[:after]
    function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
    function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]

    return function.html_safe
  end

  class JavaScriptGenerator #:nodoc:
    def initialize(context, &block) #:nodoc:
      @context, @lines = context, []
      include_helpers_from_context
      @context.with_output_buffer(@lines) do
        @context.instance_exec(self, &block)
      end
    end

    private
      def include_helpers_from_context
        extend @context.helpers if @context.respond_to?(:helpers) && @context.helpers
        extend GeneratorMethods
      end

    module GeneratorMethods
      def to_s #:nodoc:
        (@lines * $/).tap do |javascript|
          if ActionView::Base.debug_rjs
            source = javascript.dup
            javascript.replace "try {\n#{source}\n} catch (e) "
            javascript << "{ alert('RJS error:\\n\\n' + e.toString()); alert('#{source.gsub('\\','\0\0').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }}'); throw e }"
          end
        end
      end

      def [](id)
        case id
          when String, Symbol, NilClass
            JavaScriptElementProxy.new(self, id)
          else
            JavaScriptElementProxy.new(self, ActionController::RecordIdentifier.dom_id(id))
        end
      end

      def literal(code)
        ActiveSupport::JSON.encode(code.to_s)
      end

      def select(pattern)
        JavaScriptElementCollectionProxy.new(self, pattern)
      end

      def insert_html(position, id, *options_for_render)
        content = javascript_object_for(render(*options_for_render))
        record "Element.insert(\"#{id}\", { #{position.to_s.downcase}: #{content} });"
      end

      def replace_html(id, *options_for_render)
        call 'Element.update', id, render(*options_for_render)
      end

      def replace(id, *options_for_render)
        call 'Element.replace', id, render(*options_for_render)
      end

      def remove(*ids)
        loop_on_multiple_args 'Element.remove', ids
      end

      def show(*ids)
        loop_on_multiple_args 'Element.show', ids
      end

      def hide(*ids)
        loop_on_multiple_args 'Element.hide', ids
      end

      def toggle(*ids)
        loop_on_multiple_args 'Element.toggle', ids
      end

      def alert(message)
        call 'alert', message
      end

      def redirect_to(location)
        url = location.is_a?(String) ? location : @context.url_for(location)
        record "window.location.href = #{url.inspect}"
      end

      def reload
        record 'window.location.reload()'
      end

      def call(function, *arguments, &block)
        record "#{function}(#{arguments_for_call(arguments, block)})"
      end

      def assign(variable, value)
        record "#{variable} = #{javascript_object_for(value)}"
      end

      def <<(javascript)
        @lines << javascript
      end

      def delay(seconds = 1)
        record "setTimeout(function() {\n\n"
        yield
        record "}, #{(seconds * 1000).to_i})"
      end

      private
        def loop_on_multiple_args(method, ids)
          record(ids.size>1 ?
            "#{javascript_object_for(ids)}.each(#{method})" :
            "#{method}(#{javascript_object_for(ids.first)})")
        end

        def page
          self
        end

        def record(line)
          line = "#{line.to_s.chomp.gsub(/\;\z/, '')};"
          self << line
          line
        end

        def render(*options)
          with_formats(:html) do
            case option = options.first
            when Hash
              @context.render(*options)
            else
              option.to_s
            end
          end
        end

        def with_formats(*args)
          return yield unless @context

          lookup = @context.lookup_context
          begin
            old_formats, lookup.formats = lookup.formats, args
            yield
          ensure
            lookup.formats = old_formats
          end
        end

        def javascript_object_for(object)
          ::ActiveSupport::JSON.encode(object)
        end

        def arguments_for_call(arguments, block = nil)
          arguments << block_to_function(block) if block
          arguments.map { |argument| javascript_object_for(argument) }.join ', '
        end

        def block_to_function(block)
          generator = self.class.new(@context, &block)
          literal("function() { #{generator.to_s} }")
        end

        def method_missing(method, *arguments)
          JavaScriptProxy.new(self, method.to_s.camelize)
        end
    end
  end

  def update_page(&block)
    JavaScriptGenerator.new(self, &block).to_s.html_safe
  end

  def update_page_tag(html_options = {}, &block)
    javascript_tag update_page(&block), html_options
  end

  protected
    def options_for_javascript(options)
      if options.empty?
        '{}'
      else
        "{#{options.keys.map { |k| "#{k}:#{options[k]}" }.sort.join(', ')}}"
      end
    end

    def options_for_ajax(options)
      js_options = build_callbacks(options)

      js_options['asynchronous'] = options[:type] != :synchronous
      js_options['method']       = method_option_to_s(options[:method]) if options[:method]
      js_options['insertion']    = "'#{options[:position].to_s.downcase}'" if options[:position]
      js_options['evalScripts']  = options[:script].nil? || options[:script]

      if options[:form]
        js_options['parameters'] = 'Form.serialize(this)'
      elsif options[:submit]
        js_options['parameters'] = "Form.serialize('#{options[:submit]}')"
      elsif options[:with]
        js_options['parameters'] = options[:with]
      end

      if protect_against_forgery? && !options[:form]
        if js_options['parameters']
          js_options['parameters'] << " + '&"
        else
          js_options['parameters'] = "'"
        end
        js_options['parameters'] << "#{request_forgery_protection_token}=' + encodeURIComponent('#{escape_javascript form_authenticity_token}')"
      end

      options_for_javascript(js_options)
    end

    def method_option_to_s(method)
      (method.is_a?(String) and !method.index("'").nil?) ? method : "'#{method}'"
    end

    def build_callbacks(options)
      callbacks = {}
      options.each do |callback, code|
        if CALLBACKS.include?(callback)
          name = 'on' + callback.to_s.capitalize
          callbacks[name] = "function(request){#{code}}"
        end
      end
      callbacks
    end
end
