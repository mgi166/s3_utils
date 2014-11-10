module S3Utils
  class Generator
    def initialize(path)
      @path = Path.new(path)
    end

    def bucket
      s3.buckets[@path.bucket_name]
    end

    def s3_object(path=nil)
      base_path = @path.path_without_bucket
      dest_path = path ? File.join(base_path, path) : base_path
      bucket.objects[dest_path]
    end

    def s3_object_collection(path=nil)
      base_path = @path.path_without_bucket
      bucket.objects.with_prefix(base_path)
    end

    def tree
      bucket.as_tree(prefix: @path.path_without_bucket)
    end

    private

    def s3
      ::AWS::S3.new
    end
  end
end
