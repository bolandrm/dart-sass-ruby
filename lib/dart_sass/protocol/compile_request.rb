# frozen_string_literal: true

module DartSass
  module Protocol
    class CompileRequest
      def initialize(id:, content:, style:, load_paths:, syntax:, template_path: nil, source_map_contents: false)
        @id = id
        @content = content
        @template_path = template_path
        @style = style
        @load_paths = load_paths
        @syntax = syntax
        @source_map_contents = source_map_contents
      end

      def message
        Sass::EmbeddedProtocol::InboundMessage.new(
          compileRequest: Sass::EmbeddedProtocol::InboundMessage::CompileRequest.new({
            id: @id,
            string: Sass::EmbeddedProtocol::InboundMessage::CompileRequest::StringInput.new({
              source: @content,
              syntax: syntax,
              url: @template_path
            }),
            style: style,
            source_map: @source_map_contents,
            importers: importers
          })
        )
      end

      private

      def style
        Sass::EmbeddedProtocol::InboundMessage::CompileRequest::OutputStyle.const_get(@style.to_s.upcase)
      end

      def syntax
        if @syntax.to_sym == :sass
          Sass::EmbeddedProtocol::InboundMessage::Syntax::INDENTED
        else
          Sass::EmbeddedProtocol::InboundMessage::Syntax::SCSS
        end
      end

      def importers
        @load_paths.map do |path|
          Sass::EmbeddedProtocol::InboundMessage::CompileRequest::Importer.new(
            path: path
          )
        end
      end
    end
  end
end
