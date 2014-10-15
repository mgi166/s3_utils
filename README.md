# S3Utils

Simple s3 modules in order to download, upload, copy and delete the file on s3.
=======
Simple s3 modules in order to download, upload, copy and delete the file on s3.  
It is a wrapper of `aws-sdk`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 's3_utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s3_utils

## dependency

* [aws-sdk](https://github.com/aws/aws-sdk-ruby)

## Usage

```ruby
require 's3_utils'
```

### upload
```ruby
S3Utils.upload_to_s3("path/to/local_file.txt", "s3.bucket.name/path/to/s3_file.txt")
```

if the second argument has "/" in the end, upload the directory with local file basename

```ruby
S3Utils.upload_to_s3("path/to/local_file.txt", "s3.bucket.name/path/to/dir/")
=> upload to s3.bucket.name/path/to/dir/local_file.txt
=======
This module has some methods.

* `#upload_to_s3`
   * uploads the file in local to s3
* `#download_from_s3`
   * downloads from the file into local path
* `#copy_on_s3`
   * copies the file on s3 to other as `FileUtils.cp`
* `#delete_s3_file`
   * deletes the file on s3 as `FileUtils.rm`
* `#create_s3_file`
   * creates the file on s3 as `File.open`
* `#read_on_s3`
   * read the file on s3 as `File.read`

### Using module includion

```ruby
require 's3_utils'

include S3Utils

upload_to_s3('path/to/local_file.txt', 's3.bucket.name/path/to/upload_file.txt')
#=> upload to s3!

download_from_s3('s3.bucket.name/path/to/upload_file.txt', 'path/to/local_file.txt')
#=> download from s3!
```

### Using module function
```ruby
S3Utils.upload_to_s3("path/to/local_file.txt", "s3.bucket.name/path/to/dir/")
#=> upload to s3://s3.bucket.name/path/to/dir/local_file.txt

S3Utils.create_s3_file("s3.bucket.name/path/to/test.txt") do |f|
  f.puts "This is the sample text"
end
#=> create the file s3.bucket.name/path/to/test.txt that has contents "This is the sample text"
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/s3_utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
