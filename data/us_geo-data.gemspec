Gem::Specification.new do |spec|
  spec.name = "us_geo-data"
  spec.version = File.read(File.expand_path("../VERSION", __FILE__)).strip
  spec.authors = ["Brian Durand"]
  spec.email = ["bbdurand@gmail.com"]

  spec.summary = "Collection of geographic data for the United States. This is a data-only gem"
  spec.homepage = "https://github.com/bdurand/us_geo"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  ignore_files = %w[
    .
    Appraisals
    Gemfile
    Gemfile.lock
    Rakefile
    bin/
    gemfiles/
    spec/
    raw/
    processed/
  ]
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| ignore_files.any? { |path| f.start_with?(path) } }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5.0"

  spec.add_development_dependency "bundler"

  spec.required_ruby_version = ">= 2.5"
end
