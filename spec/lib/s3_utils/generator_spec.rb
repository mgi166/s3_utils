require 'fakes3/server'

describe S3Utils::Generator do
  before(:all) do
    @pid = fork do
      FakeS3::Server.new('0.0.0.0', 12345, FakeS3::FileStore.new('/var/tmp/fakes3'), 'localhost').serve
    end
    AWS.config(s3_endpoint: 'localhost', s3_force_path_style: true, s3_port: 12345, use_ssl: false)
  end

  after(:all) do
    Process.kill(:TERM, @pid) rescue nil
  end

  describe '#bucket' do
    let(:generator) { S3Utils::Generator.new('bucket/fuga/hoge') }

    it 'returns AWS::S3::Bucket instance' do
      expect(generator.bucket).to be_instance_of AWS::S3::Bucket
    end

    it 'has names bucket name' do
      expect(generator.bucket.name).to eq('bucket')
    end
  end

  describe '#s3_object' do
    let(:generator) { S3Utils::Generator.new('bucket/fuga/hoge') }

    context 'no given the argument of path' do
      it 'returns AWS::S3::Object' do
        expect(generator.s3_object).to be_instance_of AWS::S3::S3Object
      end

      it 'has the path' do
        expect(generator.s3_object.key).to eq('fuga/hoge')
      end

      it 'has the bucket' do
        expect(generator.s3_object.bucket).to eq(::AWS::S3.new.buckets['bucket'])
      end
    end

    context 'given the argument of path' do
      it 'returns AWS::S3::Object' do
        expect(generator.s3_object('bazz/spec.txt')).to be_instance_of AWS::S3::S3Object
      end

      it 'has the path' do
        expect(generator.s3_object('bazz/spec.txt').key).to eq('fuga/hoge/bazz/spec.txt')
      end

      it 'has the bucket' do
        expect(generator.s3_object.bucket).to eq(::AWS::S3.new.buckets['bucket'])
      end
    end
  end

  describe '#s3_object_collection' do
    let(:generator) { S3Utils::Generator.new('s3.bucket.com/fuga') }

    context 'when the objects exists in s3' do
      before do
        create_s3_file('s3.bucket.com/fuga/hoge.txt') {|f| f.puts '' }
        create_s3_file('s3.bucket.com/fuga/fuga.txt') {|f| f.puts '' }
      end

      after do
        delete_s3_file('s3.bucket.com/fuga/hoge.txt')
        delete_s3_file('s3.bucket.com/fuga/fuga.txt')
      end

      it 'returns the instance of AWS::S3::ObjectCollection' do
        expect(generator.s3_object_collection).to be_instance_of AWS::S3::ObjectCollection
      end

      it 'returns the s3 objects under the directory' do
        expect(
          generator.s3_object_collection.to_a
        ).to eq([S3Utils::Generator.new('s3.bucket.com/fuga/fuga.txt').s3_object, S3Utils::Generator.new('s3.bucket.com/fuga/hoge.txt').s3_object])
      end
    end
  end

  describe '#tree' do
    let(:generator) { S3Utils::Generator.new('s3.bucket.com/fuga') }

    before do
      create_s3_file('s3.bucket.com/fuga/hoge.txt') {|f| f.puts '' }
    end

    it 'returns the instance of AWS::S3::Tree' do
      expect(generator.tree).to be_instance_of AWS::S3::Tree
    end

    it 'returns the tree that has files in the argument directory' do
      expect(
        generator.tree.children.map(&:key)
      ).to eq(['fuga/hoge.txt'])
    end
  end
end
