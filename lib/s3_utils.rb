require 'aws-sdk'

module S3Utils
  def upload_to_s3(src, dest)
    d_path = Path.new(dest)

    objects = bucket(d_path.bucket_name).objects[d_path.path_without_bucket]
    objects.write(:file => src)
  end

  private

  def s3
    ::AWS::S3.new
  end

  def bucket(bucket_name)
    s3.buckets[bucket_name]
  end
end
