module S3Utils
  module Method
    def upload_to_s3(src, dest)
      d_path = Path.new(dest)
      s_path = Path.new(src)

      if s_path.file?
        upload_path = if d_path.end_with?('/')
                        File.join(d_path.path_without_bucket, s_path.basename)
                      else
                        File.join(d_path.path_without_bucket)
                      end

        objects = bucket(d_path.bucket_name).objects[upload_path]
        objects.write(:file => src)
      end

      upload_targets = unless s_path.directory?
                         Dir[s_path.to_s]
                       else
                         Dir[File.join(s_path.to_s, '**', '*')].reject do |path|
                           File.directory?(path)
                         end
                       end

      upload_targets.each do |file|
        p = File.join(d_path.path_without_bucket, file)
        upload_path = Pathname.new(p).cleanpath
        objects = bucket(d_path.bucket_name).objects[upload_path]
        objects.write(:file => file)
      end
    end

    private

    def s3
      ::AWS::S3.new
    end

    def bucket(bucket_name)
      s3.buckets[bucket_name]
    end
  end
end
