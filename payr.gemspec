$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "payr/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "payr"
  s.version     = Payr::VERSION
  s.authors     = ["Vincent Coste"]
  s.email       = ["vincent@chooseyourboss.com"]
  s.homepage    = "https://github.com/Pasta/payr"
  s.summary     = "Paybox System paiement made easy.."
  s.description = "Paybox System paiement made easy."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails", "~> 2.5"
  s.add_development_dependency "timecop"
end
