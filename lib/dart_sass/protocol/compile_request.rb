# frozen_string_literal: true

module Protocol
  class CompileRequest
    def initialize(id:, path:, style:, load_paths:)
      @id = id
      @path = path
      @style = style
      @load_paths = load_paths
    end

    def message
      Sass::EmbeddedProtocol::InboundMessage.new(
        compileRequest: Sass::EmbeddedProtocol::InboundMessage::CompileRequest.new({
          id: @id,
          path: @path,
          style: style,
          importers: importers
        })
      )
    end

    private

    def style
      Sass::EmbeddedProtocol::InboundMessage::CompileRequest::OutputStyle.const_get(@style.to_s.upcase)
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
