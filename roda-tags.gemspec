# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'roda/tags/version'

Gem::Specification.new do |spec|
  spec.name          = 'roda-tags'
  spec.version       = Roda::Tags::VERSION
  spec.authors       = ['Kematzy']
  spec.email         = ['kematzy@gmail.com']

  spec.summary       = 'A Roda Plugin providing easy creation of flexible HTML tags.'
  spec.description   = 'HTML tags functionality for Roda.'
  spec.homepage      = 'https://github.com/kematzy/roda-tags/'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.platform         = Gem::Platform::RUBY
  spec.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  spec.rdoc_options += [
    '--quiet', '--line-numbers', '--inline-source', '--title',
    'Roda-Tags: HTML tag plugin', '--main', 'README.md'
  ]

  spec.add_dependency('erubi', '~> 1.13.0', '>= 1.13.0')
  spec.add_dependency('haml', '~> 6.3.0', '>= 6.3.0')
  spec.add_dependency('roda', '>= 3.85', '< 3.88')
  spec.add_dependency('tilt', '~> 2.4.0', '>= 2.4.0')

  spec.metadata['rubygems_mfa_required'] = 'true'
end
