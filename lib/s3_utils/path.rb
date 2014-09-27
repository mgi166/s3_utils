require 'pathname'

module S3Utils
  class Path
    def initialize(path)
      @path = Pathname.new(path).cleanpath
    end
  end
end
