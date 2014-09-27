
describe S3Utils::Path do
  def path(p)
    described_class.new(p)
  end

  describe '.initialize' do
    context 'when the argument is the Object#to_str' do
      it 'returns S3Utils::Path instance' do
        expect(described_class.new('dev.spec.bucket.com')).to be_instance_of S3Utils::Path
      end
    end

    context 'when the argument is nil(not response_to? #to_str)' do
      it 'raise TypeError' do
        expect do
          described_class.new(nil)
        end.to raise_error TypeError
      end
    end
  end

  describe '#bucket_name' do
    context 'when the path is likely path of file' do
      it 'returns the first of dirname' do
        expect(path('bucket/fuga/hoge').bucket_name).to eq('bucket')
      end
    end

    context 'when the path includes "//"' do
      it 'returns the first of dirname' do
        expect(path('bucket//fuga/hoge').bucket_name).to eq('bucket')
      end
    end

    context 'when the path includes ".."' do
      it 'returns the first of dirname with cleanpath' do
        expect(path('bucket/../fuga/hoge').bucket_name).to eq('fuga')
      end
    end

    context 'when the path includes "."' do
      it 'returns the first of dirname with cleanpath' do
        expect(path('./bucket/./fuga/hoge').bucket_name).to eq('bucket')
      end
    end

    context 'when the path starts with "/"' do
      it 'returns the first of dirname removed the "/"' do
        expect(path('/bucket/fuga/hoge').bucket_name).to eq('bucket')
      end
    end

    context 'when the path is empty string' do
      it 'returns the empty' do
        expect(path('').bucket_name).to be_empty
      end
    end
  end

  describe '#path_without_bucket' do
  end
end
