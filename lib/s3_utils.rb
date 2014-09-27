require 'aws-sdk'

module S3Utils
  def upload_to_s3(src, dest)
    bucket_name = dest.split('/').first

    upload_path = File.join(dest.split('/').drop(1), File.basename(src))
    object = bucket(bucket_name).objects[upload_path]
    object.write(:file => src)
  end

  private

  def s3
    ::AWS::S3.new
  end

  def bucket(bucket_name)
    s3.buckets[bucket_name]
  end
end
