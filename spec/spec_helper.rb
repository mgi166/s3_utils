require 's3_utils'
require 'support/s3_helper'

RSpec.configure do |config|
  config.include S3Helper

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.warnings = true
  config.order = :random
end
