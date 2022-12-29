lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "nibe_uplink/version"

Gem::Specification.new do |spec|
  spec.name = "nibe_uplink-client"
  spec.version = NibeUplink::VERSION
  spec.authors = ["Erik de Bruijn"]
  spec.email = ["edb@stekker.com"]

  spec.summary = "A Ruby client for the NIBE Uplink API"
  spec.description = "This gem provides a simple Ruby client for the NIBE Uplink API."
  spec.homepage = "https://github.com/ErikdeBruijn/nibe-client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.2"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ErikdeBruijn/nibe_uplink-client"
  spec.metadata["changelog_uri"] = "https://github.com/ErikDeBruijn/nibe_uplink-client/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "json"

  spec.add_development_dependency "webmock"
  spec.add_development_dependency "webrick"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
