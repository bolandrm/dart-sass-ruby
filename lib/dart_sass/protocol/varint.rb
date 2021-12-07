module DartSass
  module Protocol
    # todo, possibly replace this with C
    # https://github.com/ruby-protobuf/protobuf/pull/269/files
    module Varint
      CACHE_LIMIT = 2048

      def self.cached_varint(value)
        @_varint_cache ||= {}
        (@_varint_cache[value] ||= encode(value, false)).dup
      end

      def self.decode(stream)
        value = index = 0

        loop do
          byte = stream.readbyte
          value |= (byte & 0x7f) << (7 * index)
          index += 1

          break unless (byte & 0x80).nonzero?
        end

        value
      end

      def self.encode(value, use_cache = true)
        return cached_varint(value) if use_cache && value >= 0 && value <= CACHE_LIMIT

        bytes = []
        until value < 128
          bytes << (0x80 | (value & 0x7f))
          value >>= 7
        end
        (bytes << value).pack("C*")
      end
    end
  end
end
