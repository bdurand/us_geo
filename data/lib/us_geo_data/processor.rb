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

          next if hash.values.all?(&:nil?)

          yield hash
        end
      ensure
        file.close if csv_file.is_a?(String)
      end
    end

    def add_demographics(entities, file, key)
      keys = Array(key)
      data = JSON.parse(File.read(data_file(file)))
      headers = {}
      data.shift.each_with_index { |h, i| headers[h] = i }

      data.each do |row|
        geoid = keys.map { |k| row[headers[k]] || (raise "Missing key #{k}") }.join
        info = entities[geoid]
        if info
          info[:population] = row[headers["B01003_001E"]]&.to_i
          info[:housing_units] = row[headers["B25001_001E"]]&.to_i
        end
      end
    end

    # Normalize a county subdivision GEOID to the current vintage. Connecticut
    # replaced its counties with planning regions as the county equivalents, but
    # the 2020 relationship files still use GEOID's based on the old counties.
    # The subdivision codes themselves did not change, so the current GEOID can
    # be looked up from the gazetteer file by the subdivision code.
    def normalize_county_subdivision_geoid(geoid)
      return geoid unless geoid&.start_with?("09")

      connecticut_county_subdivision_geoids[geoid[5, 5]] || geoid
    end

    def connecticut_county_subdivision_geoids
      unless defined?(@connecticut_county_subdivision_geoids)
        mapping = {}
        foreach(data_file(USGeoData::SUBDIVISION_GAZETTEER_FILE), col_sep: "|") do |row|
          cousub_geoid = row["GEOID"]
          mapping[cousub_geoid[5, 5]] = cousub_geoid if cousub_geoid&.start_with?("09")
        end
        @connecticut_county_subdivision_geoids = mapping
      end
      @connecticut_county_subdivision_geoids
    end

    def sort_csv_rows(csv_file_path)
      rows = File.readlines(csv_file_path)
      headers = rows.shift
      rows.sort!
      File.open(csv_file_path, "w") do |file|
        file.write(headers)
        rows.each { |row| file.write(row) }
      end
    end
  end
end
