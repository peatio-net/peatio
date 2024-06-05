lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "irix/version"

Gem::Specification.new do |spec|
  spec.name          = "irix"
  spec.version       = Irix::VERSION
  spec.authors       = ["Naichuk M."]
  spec.email         = ["mnaichuk@heliostech.fr"]

  spec.summary       = %q{Irix is implementing several crypto-exchange for Arke and Peatio.}
  spec.description   = %q{Irix is implementing several crypto-exchange for Arke and Peatio.}
  spec.homepage      = "https://www.openware.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "em-synchrony", "~> 1.0"
  spec.add_dependency "em-websocket"
  spec.add_dependency "eventmachine"
  spec.add_dependency "faraday_middleware", "~> 0.13.1"
  spec.add_dependency "faye", "~> 1.2"
  spec.add_dependency "peatio", ">= 2.4.2"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "em-spec"
  spec.add_development_dependency "em-websocket-client"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "rubocop-github"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-json"
end
