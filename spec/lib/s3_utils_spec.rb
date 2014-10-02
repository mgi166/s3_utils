require 'tmpdir'
require 'fakes3/server'

describe S3Utils do
  before(:all) do
    @pid = fork do
      FakeS3::Server.new('0.0.0.0', 12345, FakeS3::FileStore.new('/var/tmp/fakes3'), 'localhost').serve
    end
  end

  after(:all) do
    Process.kill(:TERM, @pid) rescue nil
  end

  describe '.upload_to_s3' do
    before do
      AWS.config(s3_endpoint: 'localhost', s3_force_path_style: true, s3_port: 12345, use_ssl: false)
    end

    def read_s3_file(path)
      bucket  = bucket(path)
      s3_path = s3_path(path)

      s3 = ::AWS::S3.new
      s3.buckets[bucket].objects[s3_path].read.chomp
    end

    def bucket(path)
      path.split('/', -1).first
    end

    def s3_path(path)
      path.split('/', -1).drop(1).join('/')
    end

    context 'when source is file' do
      it 'uploads the dest path' do
        src = Tempfile.new('src')
        src.write "hoge\nfuga"
        src.close

        S3Utils.upload_to_s3(src.path, 's3.bucket.com/spec/path')

        expect(read_s3_file('s3.bucket.com/spec/path')).to eq("hoge\nfuga")
      end
    end
  end
end
