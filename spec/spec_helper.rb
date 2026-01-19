# frozen_string_literal: true

require "bundler/setup"
require "logger" # needed for ActiveRecord 6

require_relative "../lib/us_geo"

require "active_record"
require "webmock/rspec"

RSpec.configure do |config|
  config.warnings = true
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end

ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => ":memory:")

Dir.glob(File.expand_path("../db/migrate/*.rb", __dir__)).sort.each do |path|
  require(path)
  class_name = File.basename(path).sub(".rb", "").split("_", 2).last.camelcase
  class_name.constantize.migrate(:up)
end

def mock_data_file_request(file_name)
  data = File.read(File.expand_path(File.join("..", "data", "2020_dist", file_name), __dir__))
  stub_request(:get, "#{USGeo.base_data_uri}/#{file_name}").to_return(body: data, headers: {"Content-Type": "text/csv; charset=UTF-8"})
end
