
describe S3Utils::Path do
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
end
