require "bundler/setup"
require_relative "../lib/us_geo"

require "active_record"
require "webmock/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => ":memory:")

Dir.glob(File.expand_path("../db/migrate/*.rb", __dir__)).each do |path|
  require(path)
  class_name = File.basename(path).sub(/\.rb/, '').split('_', 2).last.camelcase
  class_name.constantize.migrate(:up)
end
