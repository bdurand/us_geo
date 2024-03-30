# frozen_string_literal: true

module USGeoData
  module Processor
    def base_dir
      File.expand_path(File.join(__dir__, "..", ".."))
    end

    def processed_file(file_name)
      File.join(base_dir, "processed", file_name)
    end

    def data_file(file_name)
      File.join(base_dir, "raw", file_name)
    end

    def square_meters_to_miles(square_meters)
      square_meters.to_f * SQUARE_METERS_TO_MILES if square_meters
    end

    # Safely read a CSV file and yield each row as a hash.
    def foreach(csv_file, options = {}, &block)
      options = {headers: true}.merge(options)
      encoding = options.delete(:encoding) || "UTF-8"
      file = (csv_file.is_a?(String) ? File.open(csv_file, encoding: encoding) : csv_file)
      begin
        # Skip the BOM bytes if the file was exported as UTF-8 CSV from Excel
        bytes = file.read(3)
        file.rewind unless bytes == "\xEF\xBB\xBF".b
        header_mapping = nil
        CSV.new(file, **options).each do |row|
          hash = row.to_h

          # Some files can have extraneous whitespace around the header names so we need to strip it
          if header_mapping.nil?
            header_mapping = {}
            hash.keys.each do |key|
              header_mapping[key.strip] = key unless key.to_s.strip == key.to_s
            end
          end
          unless header_mapping.empty?
            header_mapping.each do |key, raw_key|
              hash[key] = hash.delete(raw_key)
            end
          end

          yield hash
        end
      ensure
        file.close if csv_file.is_a?(String)
      end
    end

    # Read a Census data file and return a hash of geoids to values.
    def demographics(file)
      data = {}

      foreach(file, col_sep: ",", skip_lines: /\A"GEO_ID"/) do |row|
        geoid = row["Geography"].split("US", 2).last
        data[geoid] = row["Estimate!!Total"].to_i
      end

      data
    end
  end
end
