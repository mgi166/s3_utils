module S3Helper
  def read_s3_file(path)
    s3_objects(path).read.chomp
  end

  def delete_s3_file(path)
    s3_objects(path).delete
  end

  def create_s3_file(path, &block)
    @tmp = Tempfile.new('')

    File.open(@tmp, "w") do |f|
      yield f
    end

    s3_objects(path).write(file: @tmp.path)
    rescue
    @tmp.close!
  end

  def s3_objects(path)
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
