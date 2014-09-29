require 's3_utils'

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.warnings = true
  config.order = :random
end
