# frozen_string_literal: true

module Protocol
  class MessageHandler
    attr_accessor :outbound_message
    attr_accessor :inbound_message
    attr_accessor :success
    attr_accessor :compile_response

    def self.process(*args)
      new(*args).process
    end

    def initialize(outbound_message)
      @outbound_message = outbound_message
    end

    def success?
      !!@success
    end

    def has_response?
      !!@inbound_message
    end

    def process
      puts "processing: #{outbound_message.to_json}"

      if outbound_message.error
        raise outbound_message.error
      end

      if (compile_response = outbound_message.compileResponse)
        if compile_response.success
          @success = true
          @compile_response = compile_response.success
        else
          puts compile_response.failure.message
          raise compile_response.failure
        end
      else
        raise "unknown response #{outbound_message.to_json}"
      end

      self
    end
  end
end
