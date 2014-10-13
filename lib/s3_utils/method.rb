module S3Utils
  module Method
    def upload_to_s3(src, dest)
      g = Generator.new(dest)

      case
      when File.file?(src)
        filename = File.basename(src.to_s) if dest.to_s.end_with?('/')
        g.s3_object(filename).write(file: src)
      when File.directory?(src)
        Dir[File.join(src, '**', '*')].each do |path|
          next if File.directory?(path)
          g.s3_object(path).write(file: path)
        end
      else
        Dir[src].each do |path|
          g.s3_object(path).write(file: path)
        end
      end
    end

    def download_from_s3(src, dest)
      g = Generator.new(src)

      if File.directory?(dest)
        download_path = File.join(dest, File.basename(src))
        File.open(download_path, 'w') do |f|
          g.s3_object.read do |chunk|
            f.write(chunk)
          end
        end
      else
        File.open(dest, 'w') do |f|
          g.s3_object.read do |chunk|
            f.write(chunk)
          end
        end
      end
    end

    def copy_on_s3(src, dest)
      gs = Generator.new(src)
      gd = Generator.new(dest)

      gs.s3_object.copy_to(gd.s3_object)
    end

    def delete_s3_file(path)
      g = Generator.new(path)
      g.s3_object.delete
    end

    def create_s3_file(path)
      g = Generator.new(path)
      @tmp = Tempfile.new('')

      File.open(@tmp, "w") do |f|
        yield f
      end

      g.s3_object.write(file: @tmp.path)
    ensure
      @tmp.close!
    end
  end
end
