describe S3Utils::Generator do
  describe '#s3_objects' do
    let(:generator) { S3Utils::Generator.new('bucket/fuga/hoge') }

    context 'no given the argument of path' do
      it 'returns AWS::S3::Object' do
        expect(generator.s3_objects).to be_instance_of AWS::S3::S3Object
      end

      it 'has the path' do
        expect(generator.s3_objects.key).to eq('fuga/hoge')
      end

      it 'has the bucket' do
        expect(generator.s3_objects.bucket).to eq(::AWS::S3.new.buckets['bucket'])
      end
    end

    context 'given the argument of path' do
      it 'returns AWS::S3::Object' do
        expect(generator.s3_objects('bazz/spec.txt')).to be_instance_of AWS::S3::S3Object
      end

      it 'has the path' do
        expect(generator.s3_objects('bazz/spec.txt').key).to eq('fuga/hoge/bazz/spec.txt')
      end

      it 'has the bucket' do
        expect(generator.s3_objects.bucket).to eq(::AWS::S3.new.buckets['bucket'])
      end
    end
  end
end