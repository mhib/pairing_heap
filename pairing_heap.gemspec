# frozen_string_literal: true

require_relative "lib/pairing_heap/version"

Gem::Specification.new do |spec|
  spec.name = "pairing_heap"
  spec.version = PairingHeap::VERSION
  spec.authors = ["Marcin Henryk Bartkowiak"]
  spec.email = ["mhbartkowiak@gmail.com"]

  spec.summary = "Performant priority queue in pure ruby with support for changing priority"
  spec.description = "Performant priority queue in pure ruby with support for changing priority using pairing heap data structure"
  spec.homepage = "https://github.com/mhib/pairing_heap"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/pairing_heap"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "simplecov", "~> 0.22.0"
  spec.add_development_dependency "standard", "~> 1.20"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
