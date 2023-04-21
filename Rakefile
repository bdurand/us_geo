begin
  require "bundler/setup"
rescue LoadError
  warn "You must `gem install bundler` and `bundle install` to run rake tasks"
end

if defined?(YARD::Rake::YardocTask)
  YARD::Rake::YardocTask.new(:yard)
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
    require_relative "data/lib/us_geo_data"
    USGeoData::Gnis.new.preprocess
  end

  desc "Generate the distribution CSV files from the raw data files and processed GNIS files"
  task :dump_dist do
    require_relative "data/lib/us_geo_data"
    USGeoData.dump_all
  end
end
