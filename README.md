# S3Utils

Simple s3 modules in order to download, upload, copy and delete the file on s3.

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
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/s3_utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
