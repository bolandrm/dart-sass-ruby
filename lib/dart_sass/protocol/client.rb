# frozen_string_literal: true

module DartSass
  module Protocol
    class Client
      def initialize
      end

      def open(&block)
        @stdin, @stdout, @waiter = Open3.popen2(embedded_bin_path)
        block.call
      ensure
        @stdin.close
        @stdout.close

        @stdin = nil
        @stdout = nil
        @waiter = nil
      end

      def write(inbound_message)
        encoded = inbound_message.to_proto
        @stdin.write(Varint.encode(encoded.bytesize))
        @stdin.write(encoded)
      end

      def get_message
        length = Varint.decode(@stdout)
        response = @stdout.read(length)
        Sass::EmbeddedProtocol::OutboundMessage.decode(response)
      end

      private

      def embedded_bin_path
        File.join(__dir__, "..", "..", "..", "bin", "sass_embedded", "dart-sass-embedded")
      end
    end
  end
end
