require 'tempfile'

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
        if g.s3_object.exists?
          download_path = File.join(dest, File.basename(src))
          File.open(download_path, 'w') do |f|
            g.s3_object.read do |chunk|
              f.write(chunk)
            end
          end
        else
          file_objects = g.tree.children(&:reaf?).map(&:object)

          file_objects.each do |obj|
            base_dir = File.basename(File.dirname(obj.key))
            obj_name = File.basename(obj.key)

            unless File.exist?(File.join(dest, base_dir))
              Dir.mkdir(File.join(dest, base_dir))
            end

            File.open(File.join(dest, base_dir, obj_name), 'w') do |f|
              obj.read { |chunk| f.write(chunk) }
            end
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
      @tmp = Tempfile.new('')
      g = Generator.new(path)

      File.open(@tmp, "w") do |f|
        yield f if block_given?
      end

      g.s3_object.write(file: @tmp.path)
    ensure
      @tmp.close! if @tmp
    end

    def read_on_s3(path)
      g = Generator.new(path)
      g.s3_object.read.chomp
    end
  end
end
