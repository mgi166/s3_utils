Dir[File.join(File.dirname(__FILE__), '../lib/**/*.rb')].each {|f| require f }

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.warnings = true
  config.order = :random
end
