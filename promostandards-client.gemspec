lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "promostandards/client/version"

Gem::Specification.new do |spec|
  spec.name          = "promostandards-client"
  spec.version       = Promostandards::Client::VERSION
  spec.authors       = ["Akshay S Murthy"]
  spec.email         = ["akshay@promohunt.com"]

  spec.summary       = %q{A Ruby client for PromoStandards}
  spec.description   = %q{A Ruby client for PromoStandards}
  spec.homepage      = "https://github.com/promohunt/promostandards-client"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3.1"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "pry-byebug", "~> 3.4.0"
  spec.add_development_dependency "parallel", "~>1.12.1"
  spec.add_development_dependency "colorize", "~>0.8.1"

  spec.add_dependency 'savon', '~> 2.12.0'
  spec.add_dependency 'httparty'
end
