$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "authhub/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "authhub"
  s.version     = Authhub::VERSION
  s.authors     = ["Giorgenes Gelatti"]
  s.email       = ["giorgenes@gmail.com"]
  s.homepage    = "http://authhub.com"
  s.summary     = "Authentication gem to interface with authhub."
  s.description = "Rails plugin to interface with authhub."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency "json"
end
