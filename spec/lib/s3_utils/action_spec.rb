
describe S3Utils::Action do
  describe '#create_file' do
    before do
      @dir = Dir.mktmpdir
    end

    let(:included_class) do
      Class.new do
        include S3Utils::Action
      end.new
    end

    context 'when dest path exist' do
      it 'creates the file on dest' do
        included_class.create_file("#{@dir}/hoge.txt") do |f|
          f.write "This is a hoge.txt"
        end

        expect(
          File.read("#{@dir}/hoge.txt")
        ).to eq('This is a hoge.txt')
      end
    end

    context 'when dest path does not exist' do
      it 'creates the file on dest' do
        included_class.create_file("#{@dir}/hoge/fuga.txt") do |f|
          f.write "This is a fuga.txt"
        end

        expect(
          File.read("#{@dir}/hoge/fuga.txt")
        ).to eq('This is a fuga.txt')
      end
    end
  end
end
