module S3Utils
  module Action
    def create_file(dest)
      path = Pathname.new(dest)
      path.dirname.mkpath
      path.open('w') do |f|
        yield f
      end
    end
  end
end
