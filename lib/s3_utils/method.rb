module S3Utils
  module Method
    def upload_to_s3(src, dest)
      d_path = Path.new(dest)
      s_path = Path.new(src)

      if s_path.file?
        upload_path = if d_path.end_with?('/')
                        d_path.join_basename(s_path)
                      else
                        d_path.path_without_bucket
                      end

        objects = bucket(d_path.bucket_name).objects[upload_path]
        objects.write(:file => src)
      else
        s_path.dir_glob.each do |file|
          upload_path = d_path.join_with_dir(file)
          objects = bucket(d_path.bucket_name).objects[upload_path]
          objects.write(:file => file)
        end
      end
    end

    def download_from_s3(src, dest)
      s_path = Path.new(src)
      d_path = Path.new(dest)

      if d_path.directory?
        objects = bucket(s_path.bucket_name).objects[s_path.path_without_bucket]
        download_path = File.join(d_path.to_s, s_path.basename)
        File.open(download_path, 'w') do |f|
          objects.read do |chunk|
            f.write(chunk)
          end
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
end
