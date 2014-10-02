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

  def create_tempfile(string)
    src = Tempfile.new('src')
    src.write "hoge\nfuga"
    src.close
    src
  end

  describe '.upload_to_s3' do
    before do
      AWS.config(s3_endpoint: 'localhost', s3_force_path_style: true, s3_port: 12345, use_ssl: false)
    end

    context 'when source is file' do
      before do
        delete_s3_file('s3.bucket.com/spec/path')
      end

      it 'exists the upload file after #upload_to_s3' do
        src = create_tempfile("aaa")

        expect do
          S3Utils.upload_to_s3(src.path, 's3.bucket.com/spec/path')
        end.to change {
          s3_objects('s3.bucket.com/spec/path').exists?
        }.from(false).to(true)
      end

      it 'uploads the dest path' do
        src = create_tempfile("hoge\nfuga")

        S3Utils.upload_to_s3(src.path, 's3.bucket.com/spec/path')

        expect(
          read_s3_file('s3.bucket.com/spec/path')
        ).to eq("hoge\nfuga")
      end
    end
  end
end
