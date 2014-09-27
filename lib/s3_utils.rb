require 'aws-sdk'

module S3Utils
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

    if s_path.directory?
      upload_targets = Dir.glob(File.join(s_path, '*'))

      upload_targets.each do |file|
        upload_path = File.join(d_path.path_without_bucket, file.basename)
        objects = bucket(d_path.bucket_name).objects[upload_path]
        objects.write(:file => src)
      end
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
