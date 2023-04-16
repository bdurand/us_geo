begin
  require "bundler/setup"
rescue LoadError
  warn "You must `gem install bundler` and `bundle install` to run rake tasks"
end

require "rdoc/task"

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "USGeo"
  rdoc.options << "--line-numbers"
  rdoc.rdoc_files.include("README.md")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

begin
  require "bundler/gem_tasks"
rescue Bundler::GemspecError
  warn "Gem tasks not available because gemspec not defined"
end

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  warn "You must install rspec to run the spec rake tasks"
end

require "standard/rake"

desc "run the specs using appraisal"
task :appraisals do
  exec "bundle exec appraisal rake spec"
end

namespace :appraisals do
  desc "install all the appraisal gemspecs"
  task :install do
    exec "bundle exec appraisal install"
  end
end

namespace :data do
  desc "Process the raw USGS GNIS file into separate CSV files"
  task :preprocess_gnis_data do
    require_relative "data/data_normalizer"
    USGeo::DataNormalizer.new.parse_gnis_data
  end

  desc "Validate that the counties_info.csv file is complete"
  task :validate_counties do
    require_relative "data/data_normalizer"
    errors = USGeo::DataNormalizer.new.validate_counties_csv
    unless errors.empty?
      errors.each do |data|
        warn "Missing values in county data:"
        data.each do |key, value|
          warn "  #{key}: #{value.inspect}"
        end
      end
      exit 1
    end
  end

  task :dump_dist do
    require_relative "data/data_normalizer"
    USGeo::DataNormalizer.new.dump_dist
  end
end
