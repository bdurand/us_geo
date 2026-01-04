begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

require "bundler/gem_tasks"

task :verify_release_branch do
  unless `git rev-parse --abbrev-ref HEAD`.chomp == "main"
    warn "Gem can only be released from the main branch"
    exit 1
  end
end

Rake::Task[:release].enhance([:verify_release_branch])

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

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

  desc "Fetch the latest demographics data from the Census API"
  task :fetch_demographics do
    require_relative "data/lib/us_geo_data"
    USGeoData.fetch_demographics_files
  end
end

namespace :db do
  desc "Dump the database schema to db/schema.rb"
  task :dump_schema do
    exec <<~BASH
      cd explorer_app
      BUNDLE_GEMFILE=$(pwd)/Gemfile bundle
      BUNDLE_GEMFILE=$(pwd)/Gemfile DATABASE_URL=sqlite3:tmp/db.sqlite3: bundle exec rails db:migrate
      rm -f tmp/db.sqlite3
      mv db/schema.rb ../db/schema.rb
    BASH
  end
end
