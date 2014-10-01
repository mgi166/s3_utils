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

  describe '#upload_to_s3' do
    before do
      AWS.config(s3_endpoint: 'localhost', s3_force_path_style: true, s3_port: 12345, use_ssl: false)
    end

    context 'when source is file' do
      subject(:upload_to_s3) do
        klass = Class.new do
          include S3Utils
        end.new

        klass.upload_to_s3('hoge', 'fuga')
      end

      it 'description' do
      end
    end
  end
end
