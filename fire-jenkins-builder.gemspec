
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fire/jenkins/builder/version"

Gem::Specification.new do |spec|
  spec.name          = "fire-jenkins-builder"
  spec.version       = Fire::Jenkins::Builder::VERSION
  spec.authors       = ["tripleCC"]
  spec.email         = ["triplec.linux@gmail.com"]

  spec.summary       = %q{2dfire jenkins builder tool.}
  spec.description   = %q{2dfire jenkins builder tool.}
  spec.homepage      = "https://github.com/tripleCC/fire-jenkins-builder"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "jenkins_api_client"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
