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
    src.write(string)
    src.close
    src
  end

  describe '.upload_to_s3' do
    context 'when source is file(not dest path end with "/")' do
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

    context 'when source is file(and dest path end with "/")' do
      before do
        delete_s3_file('s3.bucket.com/spec/path')
      end

      it 'uploads the file to under the dest path' do
        @dir = Dir.mktmpdir
        File.open(File.join(@dir, '1.txt'), 'w') {|f| f.puts "hogehoge" }

        S3Utils.upload_to_s3(File.join(@dir, '1.txt'), 's3.bucket.com/spec/path/')

        expect(
          read_s3_file('s3.bucket.com/spec/path/1.txt')
        ).to eq('hogehoge')
      end
    end

    context 'when source is directory' do
      before do
        delete_s3_file('s3.bucket.com/spec/path')

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

    context 'when source includes "*"' do
      before do
        delete_s3_file('s3.bucket.com/spec/path')

        @dir = Dir.mktmpdir
        File.open(File.join(@dir, 'abc1.txt'), 'w') {|f| f.puts "The abc1" }
        File.open(File.join(@dir, 'def1.txt'), 'w') {|f| f.puts "The def" }
        File.open(File.join(@dir, 'abc2.txt'), 'w') {|f| f.puts "The abc2" }
      end

      it "uploads the fnmatch file and doesn't upload not fmatch file" do
        S3Utils.upload_to_s3("{#@dir}/abc*.txt", 's3.bucket.com/spec/path')

        expect(
          read_s3_file("s3.bucket.com/spec/path/#{@dir}/abc1.txt")
        ).to eq('The abc1')

        expect(
          read_s3_file("s3.bucket.com/spec/path/#{@dir}/abc2.txt")
        ).to eq('The abc2')

        expect(
          s3_objects("s3.bucket.com/spec/path/#{@dir}/def1").exists?
        ).to be_falsy
      end
    end
  end
end
