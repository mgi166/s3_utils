require 'aws-sdk'
require 's3_utils/path'
require 's3_utils/method'

module S3Utils
  include Method
  extend  Method
end
