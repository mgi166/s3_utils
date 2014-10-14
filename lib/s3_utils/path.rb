require 'pathname'

module S3Utils
  class Path
    def initialize(path)
      @path = Pathname.new(path)
    end

    def bucket_name
      return '' if @path.to_s.empty? || @path.to_s == '.'

      element[0].to_s.empty? ? element[1] : element[0]
    end

    def path_without_bucket
      ele = element.drop_while(&:empty?).drop(1)
      File.join(ele)
    end

    def element
      @element ||= @path.cleanpath.to_s.split(Pathname::SEPARATOR_PAT)
    end
  end
end
