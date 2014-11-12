module S3Helper
  def read_s3_file(path)
    s3_object(path).read.chomp
  end

  def delete_on_s3(path)
    s3_object(path).delete
  end

  def create_on_s3(path, &block)
    @tmp = Tempfile.new('')

    File.open(@tmp, "w") do |f|
      yield f
    end

    s3_object(path).write(file: @tmp.path)
  ensure
    @tmp.close
  end

  def s3_object(path)
    bucket  = bucket(path)
    s3_path = s3_path(path)

    s3.buckets[bucket].objects[s3_path]
  end

  private

  def bucket(path)
    path.split('/', -1).first
  end

  def s3_path(path)
    path.split('/', -1).drop(1).join('/')
  end

  def s3
    @s3 ||= ::AWS::S3.new
  end
end
