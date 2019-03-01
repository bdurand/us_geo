# frozen_string_literal: true

require "zlib"
require "csv"
require "open-uri"

module USGeo

  class LoadError < StandardError
  end

  # Base class that all models inherit from.
  class BaseRecord < ::ActiveRecord::Base

    BASE_DATA_URI = "https://raw.githubusercontent.com/bdurand/us_geo/master/data/dist"

    self.abstract_class = true
    self.table_name_prefix = "us_geo_"

    class << self
      def load!(uri = nil)
        raise NotImplementedError
      end

      protected

      # Insert or update a record given the unique criteria for finding it.
      def load_record!(criteria, &block)
        record = find_or_initialize_by(criteria)
        record.removed = false if record.respond_to?(:removed=)
        yield(record)
        record.save!
      end

      # Mark any records not updated in the block as removed.
      def mark_removed!(&block)
        start_time = Time.at(Time.now.to_i.floor)
        yield
        raise LoadError.new("No data found") unless where("updated_at >= ?", start_time).exists?
        where("updated_at < ?", start_time).update_all(removed: true)
        where(removed: true).each do |record|
          STDERR.puts("WARNING: #{table_name}.#{record.id} has been marked removed")
        end
      end

      def delete_unmodified!(&block)
        start_time = Time.at(Time.now.to_i.floor)
        yield
        raise LoadError.new("No data found") unless where("updated_at >= ?", start_time).exists?
        where("updated_at < ?", start_time).each do
          STDERR.puts("WARNING: #{table_name} #{record.attributes.inspect} has been deleted")
        end
      end

      def load_data_file(location, &block)
        file = nil
        if location.include?(":")
          file = URI.parse(location).open(read_timeout: 5, open_timeout: 5)
        else
          file = File.open(location)
        end
        begin
          reader = (location.end_with?(".gz") ? Zlib::GzipReader.new(file) : file)
          CSV.new(reader, headers: true).each(&block)
        ensure
          file.close if file && !file.closed?
        end
      end

      # Convert square meters to square miles
      def area_meters_to_miles(square_meters)
        (square_meters.to_f / (1609.34 ** 2)).round(6)
      end
    end

  end
end
