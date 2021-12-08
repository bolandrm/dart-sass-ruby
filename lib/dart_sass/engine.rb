# frozen_string_literal: true

require "open3"
require "base64"

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
        template_path: @options[:filename],
        style: @options[:style],
        load_paths: load_paths,
        syntax: @options[:syntax],
        source_map_contents: @options[:source_map_contents]
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
      @dependencies = LoadedDependency.from_filenames(compile_response.loaded_urls)

      if @options[:source_map_contents]
        @source_map = compile_response.source_map

        if @options[:source_map_file]
          File.open(@options[:source_map_file], "w") { |f| f.write(@source_map) }
        end

        unless @options[:omit_source_map_url]
          embedded_source_map = <<-MAP
          /*
          //@ sourceMappingURL=data:application/json;base64,#{Base64.encode64(@source_map)}
          */
          MAP
          css += embedded_source_map
        end
      end

      css.dup.force_encoding(@template.encoding)
    end

    def source_map
      raise NotRenderedError unless @source_map
      @source_map
    end

    def dependencies
      @dependencies || []
    end

    def load_paths
      (@options[:load_paths] || []) + DartSass.load_paths
    end

    def filename
      @options[:filename]
    end
  end
end
