# frozen_string_literal: true

require "logger"

module DartSass
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end

  # The global load paths for Sass files. This is meant for plugins and
  # libraries to register the paths to their Sass stylesheets to that they may
  # be `@imported`. This load path is used by every instance of {Sass::Engine}.
  # They are lower-precedence than any load paths passed in via the
  # {file:SASS_REFERENCE.md#load_paths-option `:load_paths` option}.
  #
  # If the `SASS_PATH` environment variable is set,
  # the initial value of `load_paths` will be initialized based on that.
  # The variable should be a colon-separated list of path names
  # (semicolon-separated on Windows).
  #
  # Note that files on the global load path are never compiled to CSS
  # themselves, even if they aren't partials. They exist only to be imported.
  #
  # @example
  #   SassC.load_paths << File.dirname(__FILE__ + '/sass')
  # @return [Array<String, Pathname, Sass::Importers::Base>]
  def self.load_paths
    @load_paths ||= if ENV["SASS_PATH"]
      ENV["SASS_PATH"].split(File::PATH_SEPARATOR)
    else
      []
    end
  end
end

require_relative "embedded-protocol/embedded_sass_pb"
require_relative "dart_sass/version"
require_relative "dart_sass/engine"
require_relative "dart_sass/error"
require_relative "dart_sass/loaded_dependency"
require_relative "dart_sass/protocol"
require_relative "dart_sass/protocol/client"
require_relative "dart_sass/protocol/compile_request"
require_relative "dart_sass/protocol/message_handler"
require_relative "dart_sass/protocol/varint"
