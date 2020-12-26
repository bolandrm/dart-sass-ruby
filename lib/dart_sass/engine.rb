# frozen_string_literal: true

require "open3"
require "stringio"

module DartSass
  class Engine
    def initialize(template, options = {})
      @template = template
      @options = options

      @options[:syntax] ||= :scss
      @options[:style] ||= :expanded

      if @options[:precision]
        Logger.info "DEPRECATION WARNING: Dart Sass does not support passing a custom `precision`: https://github.com/sass/dart-sass#javascript-api"
      end
      if @options[:line_comments]
        Logger.info "DEPRECATION WARNING: Dart Sass does not support source comments: https://github.com/sass/dart-sass#javascript-api"
      end
    end

    def render
      compile_request = Protocol::CompileRequest.new(
        id: 1234,
        content: @template,
        template_path: @options[:template_path],
        style: @options[:style],
        load_paths: load_paths,
        syntax: @options[:syntax]
      )
      client = Protocol::Client.new
      compile_response = nil

      client.open do
        client.write(compile_request.message)

        loop do
          message = client.get_message
          handler = Protocol::MessageHandler.process(message)

          if handler.has_response?
            client.write(handler.inbound_message)
          elsif handler.success?
            compile_response = handler.compile_response
            break
          end
        end
      end

      css = compile_response.css
      css.dup.force_encoding(@template.encoding)
    end

    def source_map
      raise NotRenderedError unless @source_map
      @source_map
    end

    def load_paths
      (@options[:load_paths] || []) + DartSass.load_paths
    end
  end
end
