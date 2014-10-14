# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3_utils/version'

Gem::Specification.new do |spec|
  spec.name          = "s3_utils"
  spec.version       = S3Utils::VERSION
  spec.authors       = ["mgi166"]
  spec.email         = ["skskoari@gmail.com"]
  spec.summary       = %q{Simple s3 modules in order to download, upload, copy and delete the file on s3.}
  spec.description   = %q{Simple s3 modules in order to download, upload, copy and delete the file on s3.}
  spec.homepage      = "https://github.com/mgi166/s3_utils"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakes3"
end
