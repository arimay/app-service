# frozen_string_literal: true

require_relative "lib/app/service/version"

Gem::Specification.new do |spec|
  spec.name          = "app-service"
  spec.version       = App::Service::VERSION
  spec.authors       = ["arimay"]
  spec.email         = ["arima.yasuhiro@gmail.com"]

  spec.summary       = %q{ Service application daemonize. }
  spec.description   = %q{ App::Service is a library for service application daemonize. }
  spec.homepage      = "https://github.com/arimay/app-service"
  spec.license       = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
