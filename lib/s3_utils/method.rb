require 'tempfile'
require 's3_utils/action'

module S3Utils
  module Method
    include Action

    def self.included(klass)
      klass.extend(self)
    end

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

      if g.s3_object.exists?
        download_path = File.directory?(dest) ? File.join(dest, File.basename(src)) : dest
        create_file(download_path) do |f|
          g.s3_object.read { |chunk| f.write(chunk) }
        end
      else
        file_objects = g.tree.children(&:reaf?).map(&:object)

        file_objects.each do |obj|
          next unless obj.exists?

          base_dir = File.basename(File.dirname(obj.key))
          obj_name = File.basename(obj.key)

          create_file(File.join(dest, base_dir, obj_name)) do |f|
            obj.read { |chunk| f.write(chunk) }
          end
        end
      end
    end

    def copy_on_s3(src, dest)
      gs = Generator.new(src)
      gd = Generator.new(dest)

      gs.s3_object.copy_to(gd.s3_object)
    end

    def delete_on_s3(path)
      g = Generator.new(path)
      g.s3_object.delete
    end

    def create_on_s3(path)
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
