require 'tmpdir'
require 'fakes3/server'

describe S3Utils do
  before(:all) do
    @pid = fork do
      FakeS3::Server.new('0.0.0.0', 12345, FakeS3::FileStore.new('/var/tmp/fakes3'), 'localhost').serve
    end
    AWS.config(s3_endpoint: 'localhost', s3_force_path_style: true, s3_port: 12345, use_ssl: false)
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

      it 'uploads the file to dest path' do
        src = create_tempfile("hoge\nfuga")

        S3Utils.upload_to_s3(src.path, 's3.bucket.com/spec/path')

        expect(
          read_s3_file('s3.bucket.com/spec/path')
        ).to eq("hoge\nfuga")
      end
    end

    context 'when source is directory' do
      before do
        @dir = Dir.mktmpdir
        File.open(File.join(@dir, '1.txt'), 'w') {|f| f.puts "The one" }
        File.open(File.join(@dir, '2.txt'), 'w') {|f| f.puts "The two" }
      end

      it 'uploads the file with directoy to dest path' do
        S3Utils.upload_to_s3(@dir, 's3.bucket.com/spec/path')

        expect(
          read_s3_file("s3.bucket.com/spec/path/#{@dir}/1.txt")
        ).to eq('The one')

        expect(
          read_s3_file("s3.bucket.com/spec/path/#{@dir}/2.txt")
        ).to eq('The two')
      end
    end
  end
end
