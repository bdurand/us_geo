lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "us_geo/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "us_geo"
  s.version     = USGeo::VERSION
  s.authors     = ["Brian Durand"]
  s.summary     = "Collection of county level data for the United States for use with ActiveRecord"
  s.license     = "MIT"

  s.files = Dir["{db,lib}/**/*", "Rakefile", "README.md", "Gemfile", "Gemfile.lock"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'activerecord', '~> 5.0'

  s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'sqlite3', '~> 1.3.0'
  s.add_development_dependency "webmock", '~> 3.4'
  s.add_development_dependency "appraisal"
end
