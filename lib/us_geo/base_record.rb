# frozen_string_literal: true

require "zlib"
require "csv"
require "open-uri"

module USGeo

  class LoadError < StandardError
  end

  # Base class that all models inherit from.
  class BaseRecord < ::ActiveRecord::Base

    self.abstract_class = true
    self.table_name_prefix = "us_geo_"

    class << self
      def load!(location = nil, gzipped: true)
        raise NotImplementedError
      end

      protected

      # Insert or update a record given the unique criteria for finding it.
      def load_record!(criteria, &block)
        record = find_or_initialize_by(criteria)
        record.removed = false if record.respond_to?(:removed=)
        record.updated_at = Time.now if record.respond_to?(:updated_at=)
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

      def data_uri(path)
        path = path.to_s if path
        if path.start_with?("/") || path.include?(":")
          path
        elsif USGeo.base_data_uri.include?(":")
          "#{USGeo.base_data_uri}/#{path}"
        else
          File.join(USGeo.base_data_uri, path)
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
          rows = []
          CSV.new(reader, headers: true).each do |row|
            rows << row
            if rows.size >= 50
              transaction { rows.each(&block) }
              rows.clear
            end
          end
          transaction { rows.each(&block) } unless rows.empty?
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
