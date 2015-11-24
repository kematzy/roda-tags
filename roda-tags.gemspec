# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roda/tags/version'

Gem::Specification.new do |spec|
  spec.name          = "roda-tags"
  spec.version       = Roda::Tags::VERSION
  spec.authors       = ["Kematzy"]
  spec.email         = ["kematzy@gmail.com"]

  spec.summary       = %q{A Roda Plugin providing easy creation of flexible HTML tags.}
  spec.description   = %q{HTML tags functionality for Roda.}
  spec.homepage      = "https://github.com/kematzy/roda-tags/"
  spec.license       = "MIT"

  # # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.platform         = Gem::Platform::RUBY
  spec.has_rdoc         = true
  spec.extra_rdoc_files = ["README.md", "MIT-LICENSE"]
  spec.rdoc_options     += ["--quiet", "--line-numbers", "--inline-source", '--title', 'Roda-Tags: HTML tag plugin', '--main', 'README.md']
  
  spec.add_runtime_dependency 'roda'
  spec.add_runtime_dependency 'tilt'
  spec.add_runtime_dependency 'erubis'
  
  spec.add_development_dependency 'bundler', "~> 1.10"
  spec.add_development_dependency 'rake', "~> 10.0"
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-hooks'
  spec.add_development_dependency 'minitest-rg'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'nokogiri'
  spec.add_development_dependency 'simplecov'
  
end
