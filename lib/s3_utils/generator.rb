module S3Utils
  class Generator
    def initialize(path)
      @path = Path.new(path)
    end

    def s3_object(path=nil)
      base_path = @path.path_without_bucket
      dest_path = path ? File.join(base_path, path) : base_path
      bucket(@path.bucket_name).objects[dest_path]
    end

    def s3_object_collection(path=nil)
      base_path = @path.path_without_bucket
      bucket(@path.bucket_name).objects.with_prefix(base_path)
    end

    def s3
      ::AWS::S3.new
    end

    def bucket(bucket_name)
      s3.buckets[bucket_name]
    end
  end
end
