module S3Utils
  module Method
    def upload_to_s3(src, dest)
      g = Generator.new(dest)

      case
      when File.file?(src)
        filename = File.basename(src.to_s) if dest.to_s.end_with?('/')
        g.s3_objects(filename).write(file: src)
      when File.directory?(src)
        Dir[File.join(src, '**', '*')].each do |path|
          next if File.directory?(path)
          g.s3_objects(path).write(file: path)
        end
      else
        Dir[src].each do |path|
          g.s3_objects(path).write(file: path)
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
      else
        objects = bucket(s_path.bucket_name).objects[s_path.path_without_bucket]
        File.open(d_path.to_s, 'w') do |f|
          objects.read do |chunk|
            f.write(chunk)
          end
        end
      end
    end

    def copy_on_s3(src, dest)
      s_path = Path.new(src)
      d_path = Path.new(dest)

      s_objects = bucket(s_path.bucket_name).objects[s_path.path_without_bucket]
      d_objects = bucket(d_path.bucket_name).objects[d_path.path_without_bucket]

      s_objects.copy_to(d_objects)
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
