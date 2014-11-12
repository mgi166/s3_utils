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
        delete_on_s3('s3.bucket.com/spec/path')
      end

      it 'exists the upload file after #upload_to_s3' do
        src = create_tempfile("aaa")

        expect do
          S3Utils.upload_to_s3(src.path, 's3.bucket.com/spec/path')
        end.to change {
          s3_object('s3.bucket.com/spec/path').exists?
        }.from(false).to(true)
      end

      it 'uploads the file to dest path' do
        src = create_tempfile("hoge\nfuga")

        S3Utils.upload_to_s3(src.path, 's3.bucket.com/spec/path')

        expect(
          read_on_s3('s3.bucket.com/spec/path')
        ).to eq("hoge\nfuga")
      end
    end

    context 'when source is file(and dest path end with "/")' do
      before do
        delete_on_s3('s3.bucket.com/spec/path')
      end

      after { FileUtils.remove_entry_secure(@dir) if Dir.exist?(@dir) }

      it 'uploads the file to under the dest path' do
        @dir = Dir.mktmpdir
        File.open(File.join(@dir, '1.txt'), 'w') {|f| f.puts "hogehoge" }

        S3Utils.upload_to_s3(File.join(@dir, '1.txt'), 's3.bucket.com/spec/path/')

        expect(
          read_on_s3('s3.bucket.com/spec/path/1.txt')
        ).to eq('hogehoge')
      end
    end

    context 'when source is directory' do
      before do
        delete_on_s3('s3.bucket.com/spec/path')

        @dir = Dir.mktmpdir
        File.open(File.join(@dir, '1.txt'), 'w') {|f| f.puts "The one" }
        File.open(File.join(@dir, '2.txt'), 'w') {|f| f.puts "The two" }
      end

      after { FileUtils.remove_entry_secure(@dir) if Dir.exist?(@dir) }

      it 'uploads the file with directoy to dest path' do
        S3Utils.upload_to_s3(@dir, 's3.bucket.com/spec/path')

        expect(
          read_on_s3("s3.bucket.com/spec/path/#{@dir}/1.txt")
        ).to eq('The one')

        expect(
          read_on_s3("s3.bucket.com/spec/path/#{@dir}/2.txt")
        ).to eq('The two')
      end
    end

    context 'when source includes "*"' do
      before do
        delete_on_s3('s3.bucket.com/spec/path')

        @dir = Dir.mktmpdir
        File.open(File.join(@dir, 'abc1.txt'), 'w') {|f| f.puts "The abc1" }
        File.open(File.join(@dir, 'def1.txt'), 'w') {|f| f.puts "The def" }
        File.open(File.join(@dir, 'abc2.txt'), 'w') {|f| f.puts "The abc2" }
      end

      after { FileUtils.remove_entry_secure(@dir) if Dir.exist?(@dir) }

      it "uploads the fnmatch file and doesn't upload not fmatch file" do
        S3Utils.upload_to_s3("{#@dir}/abc*.txt", 's3.bucket.com/spec/path')

        expect(
          read_on_s3("s3.bucket.com/spec/path/#{@dir}/abc1.txt")
        ).to eq('The abc1')

        expect(
          read_on_s3("s3.bucket.com/spec/path/#{@dir}/abc2.txt")
        ).to eq('The abc2')

        expect(
          s3_object("s3.bucket.com/spec/path/#{@dir}/def1").exists?
        ).to be false
      end
    end
  end

  describe '.download_from_s3' do
    context 'when dest path is directory' do
      before do
        delete_on_s3('s3.bucket.com/spec/path')
        create_on_s3('s3.bucket.com/spec/path/hoge.txt') {|f| f.write "hoge"}
        @dir = Dir.mktmpdir
      end

      after { FileUtils.remove_entry_secure(@dir) if Dir.exist?(@dir) }

      it 'downloads the file in the directory' do
        S3Utils.download_from_s3('s3.bucket.com/spec/path/hoge.txt', @dir)

        expect(File.read("#{@dir}/hoge.txt")).to eq('hoge')
      end
    end

    context 'when dest path is file' do
      before do
        delete_on_s3('s3.bucket.com/spec/path')
        create_on_s3('s3.bucket.com/spec/path/fuga.txt') {|f| f.write "fuga"}
        @dir = Dir.mktmpdir
      end

      after { FileUtils.remove_entry_secure(@dir) if Dir.exist?(@dir) }

      it 'downloads the file as local file' do
        dest_file = File.join(@dir, 'fuga.txt')
        S3Utils.download_from_s3('s3.bucket.com/spec/path/fuga.txt', dest_file)

        expect(File.read(dest_file)).to eq('fuga')
      end
    end

    describe 'when the src is directory' do
      context 'the dest directory is already exists' do
        before do
          delete_on_s3('s3.bucket.com/spec/path')
          create_on_s3('s3.bucket.com/spec/path/fuga.txt') {|f| f.write "fuga"}
          create_on_s3('s3.bucket.com/spec/path/bazz.txt') {|f| f.write "bazz"}
          @dir = Dir.mktmpdir
        end

        after { FileUtils.remove_entry_secure(@dir) if Dir.exist?(@dir) }

        it 'downloads the directory in dest directory' do
          S3Utils.download_from_s3('s3.bucket.com/spec/path', @dir)
          expect(Dir["#{@dir}/path/**/*"]).to eq([ "#{@dir}/path/bazz.txt", "#{@dir}/path/fuga.txt"])
        end
      end
    end
  end

  describe '.copy_on_s3' do
    before do
      delete_on_s3('s3.bucket.com/spec/path')
      create_on_s3('s3.bucket.com/spec/path/hoge.txt') {|f| f.write "hoge"}
    end

    it 'copy src object to dest' do
      S3Utils.copy_on_s3('s3.bucket.com/spec/path/hoge.txt', 's3.bucket.com/spec/path/fuga.txt')

      expect(
        read_on_s3("s3.bucket.com/spec/path/fuga.txt")
      ).to eq('hoge')
    end
  end

  describe '.delete_on_s3' do
    context 'when the argument is file on s3' do
      before do
        create_on_s3('s3.bucket.com/spec/path/hoge.txt') {|f| f.write "hoge"}
      end

      it 'returns nil' do
        expect(
          S3Utils.delete_on_s3('s3.bucket.com/spec/path/dir/hoge.txt')
        ).to be_nil
      end

      it 'deletes the argument file on s3' do
        expect do
          S3Utils.delete_on_s3('s3.bucket.com/spec/path/hoge.txt')
        end.to change {
          s3_object('s3.bucket.com/spec/path/hoge.txt').exists?
        }.from(true).to(false)
      end
    end

    context 'when the argument is directory on s3' do
      before do
        create_on_s3('s3.bucket.com/spec/path/dir/hoge.txt') {|f| f.write "hoge"}
      end

      it 'deletes the argument directory on s3' do
        expect do
          S3Utils.delete_on_s3('s3.bucket.com/spec/path/dir')
        end.to change {
          s3_object('s3.bucket.com/spec/path/dir/hoge.txt').exists?
        }.from(true).to(false)
      end
    end

    context "when the argument doesn't exist on s3" do
      before do
        delete_on_s3('s3.bucket.com/spec/path/dir/hoge.txt')
      end

      it 'returns nil' do
        expect(
          S3Utils.delete_on_s3('s3.bucket.com/spec/path/dir/hoge.txt')
        ).to be_nil
      end

      it 'keeps of not existance' do
        expect do
          S3Utils.delete_on_s3('s3.bucket.com/spec/path/dir/hoge.txt')
        end.to_not change {
          s3_object('s3.bucket.com/spec/path/dir/hoge.txt').exists?
        }.from(false)
      end
    end
  end

  describe '.create_on_s3' do
    context "when the file doesn't exist on s3" do
      before do
        delete_on_s3('s3.bucket.com/spec/path')
      end

      it 'creates the file on s3' do
        S3Utils.create_on_s3('s3.bucket.com/spec/path/test.txt') do |f|
          f.puts "aaaa"
          f.puts "bbbb"
          f.puts "cccc"
        end

        expect(
          read_on_s3('s3.bucket.com/spec/path/test.txt')
        ).to eq("aaaa\nbbbb\ncccc")
      end
    end

    context 'when the file already exist on s3' do
      before do
        create_on_s3('s3.bucket.com/spec/path/test.txt') do |f|
          f.puts "already exist"
        end
      end

      it 'overwrites the contents' do
        S3Utils.create_on_s3('s3.bucket.com/spec/path/test.txt') do |f|
          f.puts "overwrite the contents"
        end

        expect(
          read_on_s3('s3.bucket.com/spec/path/test.txt')
        ).to eq("overwrite the contents")
      end
    end

    context 'when no block given' do
      before do
        delete_on_s3('s3.bucket.com/spec/path/test.txt')
      end

      it 'creates empty file on s3' do
        S3Utils.create_on_s3('s3.bucket.com/spec/path/test.txt')

        expect(read_on_s3('s3.bucket.com/spec/path/test.txt')).to be_empty
      end
    end
  end

  describe '.read_on_s3' do
    context 'when the file exists' do
      before do
        create_on_s3('s3.bucket.com/spec/path/test.txt') {|f| f.puts "test" }
      end

      it 'returns the String that the file contains' do
        expect(
          S3Utils.read_on_s3('s3.bucket.com/spec/path/test.txt')
        ).to eq('test')
      end
    end

    context "when the file doesn't exists" do
      before do
        delete_on_s3('s3.bucket.com/spec/path/test.txt')
      end

      it 'raises error' do
        expect do
          S3Utils.read_on_s3('s3.bucket.com/spec/path/test.txt')
        end.to raise_error AWS::S3::Errors::NoSuchKey
      end
    end
  end
end
