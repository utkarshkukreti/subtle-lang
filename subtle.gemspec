# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'subtle/version'

Gem::Specification.new do |gem|
  gem.name          = "subtle"
  gem.version       = Subtle::VERSION
  gem.authors       = ["Utkarsh Kukreti"]
  gem.email         = ["utkarshkukreti@gmail.com"]
  gem.description   = %q{Subtle is a Terse, Array based Programming Language,
                         heavily inspired by the K Programming Language, and
                         partly by APL and J.}
  gem.summary       = %q{Subtle is a Terse, Array based Programming Language,
                         heavily inspired by the K Programming Language, and
                         partly by APL and J.}
  gem.homepage      = "https://github.com/utkarshkukreti/subtle-lang"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "parslet"

  %w{rspec guard-rspec simplecov pry pry-debugger}.each do |name|
    gem.add_development_dependency name
  end
end
