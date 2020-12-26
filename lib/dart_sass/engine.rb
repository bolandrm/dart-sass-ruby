# frozen_string_literal: true

require "open3"
require "tempfile"
require "stringio"

module DartSass
  class Engine
    def initialize(template, options = {})
      @template = template
      @options = options

      if @options[:precision]
        Logger.info "DEPRECATION WARNING: Dart Sass does not support passing a custom `precision`: https://github.com/sass/dart-sass#javascript-api"
      end
      if @options[:line_comments]
        Logger.info "DEPRECATION WARNING: Dart Sass does not support source comments: https://github.com/sass/dart-sass#javascript-api"
      end
    end

    def render
      tempfile = Tempfile.new
      tempfile.write(@template)
      tempfile.rewind

      compile_request = Protocol::CompileRequest.new(
        id: 1234,
        path: tempfile.path,
        style: :expanded,
        load_paths: load_paths
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
    ensure
      tempfile.close
      tempfile.unlink # deletes the temp file
    end

    def load_paths
      (@options[:load_paths] || []) + DartSass.load_paths
    end
  end
end
