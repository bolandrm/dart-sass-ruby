module DartSass
  class LoadedDependency
    attr_reader :filename

    def initialize(filename)
      @filename = filename.gsub(/^file:\/\//, "")
    end

    def options
      {filename: filename}
    end
  end
end
