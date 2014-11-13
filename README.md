[![Coverage Status](https://coveralls.io/repos/mgi166/s3_utils/badge.png?branch=master)](https://coveralls.io/r/mgi166/s3_utils?branch=master)
[![Code Climate](https://codeclimate.com/github/mgi166/s3_utils/badges/gpa.svg)](https://codeclimate.com/github/mgi166/s3_utils)

# S3Utils
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

This module has some methods.

* `#upload_to_s3`
   * uploads the file in local to s3
* `#download_from_s3`
   * downloads from the file into local path
* `#copy_on_s3`
   * copies the file on s3 to other as `FileUtils.cp`
* `#delete_on_s3`
   * deletes the file on s3 as `FileUtils.rm`
* `#create_on_s3`
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
require 's3_utils'

S3Utils.upload_to_s3("path/to/local_file.txt", "s3.bucket.name/path/to/dir/")
#=> upload to "s3://s3.bucket.name/path/to/dir/local_file.txt"

S3Utils.create_on_s3("s3.bucket.name/path/to/test.txt") do |f|
  f.puts "This is the sample text"
end
#=> create the file "s3.bucket.name/path/to/test.txt" that has contents "This is the sample text"
```

## Methods
### upload_to_s3
Uploads the file in local path to s3.  
when destination url has the string end with "/", upload the local file under the directory.

```ruby
S3Utils.upload_to_s3('path/to/local_file.txt', 's3.bucket.name/path/to/upload_file.txt')
#=> Upload from "path/to/local_file.txt" to "s3.bucket.name/path/to/upload_file.txt"

S3Utils.upload_to_s3("path/to/local_file.txt", "s3.bucket.name/path/to/dir/")
#=> Upload from "path/to/local_file.txt" to "s3://s3.bucket.name/path/to/dir/local_file.txt"
```

### download_from_s3
Downloads the file in s3 to local path.  
When local path is directory, download to under the local directory.

```ruby
S3Utils.download_from_s3('s3.bucket.name/path/to/upload_file.txt', 'path/to/local_file.txt')
#=> Download from "s3.bucket.name/path/to/upload_file.txt" to "path/to/local_file.txt"

# path/to/dir is directory
S3Utils.download_from_s3('s3.bucket.name/path/to/upload_file.txt', 'path/to/dir')
#=> Donwload from "s3.bucket.name/path/to/upload_file.txt" to "path/to/dir/upload_file.txt"
```

### copy_on_s3
Copy the file in s3 to another.  

```ruby
S3Utils.copy_on_s3('s3.bucket.com/path/to/source.txt', 's3.bucket.com/path/to/dest.txt')
#=> Copy from "s3.bucket.com/path/to/source.txt" to "s3.bucket.com/path/to/dest.txt"
```

### delete_on_s3
Delete the file in s3.  

```ruby
S3Utils.delete_on_s3('s3.bucket.com/path/to/source.txt')
#=> Delete "s3.bucket.com/path/to/source.txt"
```

### create_on_s3
Create the file in s3.  
If block given, it will be passed the File object and uploads to s3.

```ruby
S3Utils.create_on_s3('s3.bucket.com/path/to/file.txt')
#=> Create "s3.bucket.com/path/to/source.txt" but it is empty file

S3Utils.create_on_s3('s3.bucket.com/path/to/file.txt') do |f|
  f.puts "the file in s3"
end
#=> Create "s3.bucket.com/path/to/source.txt" and it has the contents "the file in s3"
```

### read_on_s3
Read the file in s3.  

```ruby
# s3.bucket.com/path/to/file.txt has contents "abcdefg"
S3Utils.read_on_s3('s3.bucket.com/path/to/file.txt')
#=> abcdefg
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/s3_utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
