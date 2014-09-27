require 'pathname'
require 'forwardable'

module S3Utils
  class Path
    extend Forwardable

    def initialize(path)
      @path = Pathname.new(path).cleanpath
    end

    def_delegators :@path, :basename, :directory?, :file?

    def bucket_name
      return '' if @path.to_s == '.'

      element[0].to_s.empty? ? element[1] : element[0]
    end

    def path_without_bucket
      ele = element.drop_while(&:empty?).drop(1)
      File.join(ele)
    end

    def element
      @element ||= @path.to_s.split(Pathname::SEPARATOR_PAT)
    end

    def end_with?(suffix)
      @path.to_s.end_with?(suffix)
    end
  end
end
