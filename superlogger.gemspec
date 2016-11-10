$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "superlogger/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "superlogger"
  s.version     = Superlogger::VERSION
  s.authors     = ["Soh Yu Ming"]
  s.email       = ["sohymg@gmail.com"]
  s.homepage    = "https://github.com/moexmen/superlogger"
  s.summary     = "Machine-readable logging for Rails"
  s.description = "Machine-readable logging for Rails"
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  if ENV['RAILS_VERSION'] == '4'
    s.add_dependency 'rails', '~> 4.0'
  else
    s.add_dependency 'rails'
  end

  s.add_dependency 'request_store'
end
