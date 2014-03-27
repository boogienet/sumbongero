# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sumbongero/version'

Gem::Specification.new do |spec|
  spec.name          = "sumbongero"
  spec.version       = Sumbongero::VERSION
  spec.authors       = ["Ritchie Macapinlac"]
  spec.email         = ["info+app@boogienet.com"]
  spec.description   = %q{Sumbongero is an application that provides data}
  spec.summary       = %q{An application that reads your data and provides summaries}
  spec.homepage      = "http://www.boogienet.com/"
  spec.license       = "MIT"

  spec.bindir        = 'bin'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'log4r'
  spec.add_dependency 'ruby-gmail'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
