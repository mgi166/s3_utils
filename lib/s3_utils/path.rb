require 'pathname'

module S3Utils
  class Path
    def initialize(path)
      @path = Pathname.new(path).cleanpath
    end

    def bucket_name
      return '' if @path.to_s == '.'

      element.first.to_s.empty? ? element[1] : element[0]
    end

    def path_without_bucket
      File.join(element.drop(1))
    end

    def element
      @element ||= @path.to_s.split(Pathname::SEPARATOR_PAT)
    end
  end
end
