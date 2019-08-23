lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "train-serial/version"

Gem::Specification.new do |spec|
  spec.name          = "train-serial"
  spec.version       = TrainPlugins::Serial::VERSION
  spec.authors       = ["Thomas Heinen"]
  spec.email         = ["theinen@tecracer.de"]
  spec.summary       = "Train Transport for serial/USB interfaces"
  spec.description   = "Allows applications using Train to speak to serial interaces, like console ports"
  spec.homepage      = "https://github.com/tecracer_theinen/train-serial"
  spec.license       = "Apache-2.0"

  spec.files = %w{
    README.md train-serial.gemspec Gemfile
  } + Dir.glob(
    "lib/**/*", File::FNM_DOTMATCH
  ).reject { |f| File.directory?(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "train", "~> 2.0"
  spec.add_dependency "rubyserial", "~> 0.6"
end
