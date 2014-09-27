require 'pathname'

module S3Utils
  class Path
    def initialize(path)
      @path = Pathname.new(path).cleanpath
    end

    def bucket_name
      return '' if @path.to_s == '.'

      ele = @path.to_s.split(Pathname::SEPARATOR_PAT)
      ele.first.to_s.empty? ? ele[1] : ele[0]
    end
  end
end
