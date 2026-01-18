# frozen_string_literal: true

module USGeoData
  class Gnis
    include Processor

    # See https://www.census.gov/library/reference/code-lists/class-codes.html
    # Ignoring C9 since these tend to be ghost towns
    FIPS_CLASSIFICATIONS = {
      "C1" => [:place],
      "C2" => [:place],
      "C3" => [:place],
      "C4" => [:place],
      "C5" => [:place, :subdivision],
      "C6" => [:place, :subdivision],
      "C7" => [:county, :place],
      "H1" => [:county],
      "H4" => [:county],
      "H5" => [:county],
      "H6" => [:county],
      "M1" => [:place],
      "M2" => [:place],
      "P1" => [:place],
      "P2" => [:place],
      "T1" => [:subdivision],
      "T2" => [:subdivision],
      "T5" => [:subdivision],
      "T9" => [:subdivision],
      "U1" => [:place],
      "U2" => [:place],
      "U6" => [:non_census_place],
      "Z1" => [:subdivision],
      "Z2" => [:subdivision],
      "Z3" => [:subdivision],
      "Z5" => [:subdivision]
    }.freeze

    COUNTIES_FILE = "gnis_counties.csv"
    SUBDIVISIONS_FILE = "gnis_subdivisions.csv"
    PLACES_FILE = "gnis_places.csv"
    PLACE_COUNTIES_FILE = "gnis_place_counties.csv"

    # Parse out the data from the USGS names with federal codes file into more manageable chunks.
    def preprocess
      counties_file_path = processed_file(COUNTIES_FILE)
      subdivisions_file_path = processed_file(SUBDIVISIONS_FILE)
      places_file_path = processed_file(PLACES_FILE)
      place_counties_file_path = processed_file(PLACE_COUNTIES_FILE)
      non_census_places_file_path = processed_file("gnis_non_census_places.csv")
      gnis_data_file_path = data_file(USGeoData::GNIS_DATA_FILE)

      zctas_gis = ZCTAShape.new(data_file(USGeoData::ZCTA_GIS_DB_FILE))

      counties_file = File.open(counties_file_path, "w")
      subdivisions_file = File.open(subdivisions_file_path, "w")
      places_file = File.open(places_file_path, "w")
      place_counties_file = File.open(place_counties_file_path, "w")
      non_census_places_file = File.open(non_census_places_file_path, "w")

      begin
        counties_csv = CSV.new(counties_file)
        subdivisions_csv = CSV.new(subdivisions_file)
        places_csv = CSV.new(places_file)
        place_counties_csv = CSV.new(place_counties_file)
        non_census_places_csv = CSV.new(non_census_places_file)

        counties_csv << ["GNIS ID", "GEOID", "Name", "Short Name", "State", "FIPS Class", "Latitude", "Longitude"]
        subdivisions_csv << ["GNIS ID", "GEOID", "Name", "State", "FIPS Class", "County GEOID", "Latitude", "Longitude"]
        places_csv << ["GNIS ID", "GEOID", "Name", "State", "FIPS Class", "County GEOID", "Latitude", "Longitude"]
        place_counties_csv << ["Place GEOID", "County GEOID"]
        non_census_places_csv << ["GNIS ID", "GEOID", "Name", "State", "FIPS Class", "County GEOID", "ZCTA", "Latitude", "Longitude"]

        lock = Mutex.new
        row_count = File.readlines(gnis_data_file_path).size - 1
        current_row = 0
        t = Time.now

        foreach(gnis_data_file_path, col_sep: "|", quote_char: nil) do |row|
          if current_row % 1000 == 0
            elapsed = (Time.now - t).round
            puts("Processing GNIS file (#{((current_row.to_f / row_count.to_f) * 100.0).round(1)}% - #{elapsed}s)")
          end
          current_row += 1

          fips_class_code = row["census_class_code"]
          gnis_id = row["feature_id"].to_i
          name = row["feature_name"]
          state_fips = row["state_numeric"]
          state_code = lookup_state_code(row["state_name"])
          geoid = "#{state_fips}#{row["census_code"]}"
          county_geoid = "#{state_fips}#{row["county_numeric"]}"
          lat = row["prim_lat_dec"]
          lng = row["prim_long_dec"]
          county_num = row["county_sequence"].to_i

          if county?(fips_class_code)
            county_name = row["county_name"].to_s
            county_name = name if county_name.empty?
            lock.synchronize do
              counties_csv << [gnis_id, county_geoid, name, county_name, state_code, fips_class_code, lat, lng]
            end
          end

          if subdivision?(fips_class_code) && county_num == 1
            geoid = "#{state_fips}#{row["county_numeric"]}#{row["census_code"]}"
            lock.synchronize do
              subdivisions_csv << [gnis_id, geoid, name, state_code, fips_class_code, county_geoid, lat, lng]
            end
          end

          if place?(fips_class_code)
            if county_num == 1
              lock.synchronize do
                places_csv << [gnis_id, geoid, name, state_code, fips_class_code, county_geoid, lat, lng]
                place_counties_csv << [geoid, county_geoid]
              end
            end
          elsif non_census_place?(fips_class_code)
            if county_num == 1
              zcta = zctas_gis.including(lat.to_f, lng.to_f)
              lock.synchronize do
                non_census_places_csv << [gnis_id, geoid, name, state_code, fips_class_code, county_geoid, zcta, lat, lng]
              end
            end
          end
        rescue => e
          warn "Error processing GNIS row: #{row.inspect}: #{e.message}"
        end
      ensure
        counties_file.close
        subdivisions_file.close
        places_file.close
        place_counties_file.close
        non_census_places_file.close
      end

      sort_csv_rows(counties_file_path)
      sort_csv_rows(subdivisions_file_path)
      sort_csv_rows(places_file_path)
      sort_csv_rows(place_counties_file_path)
      sort_csv_rows(non_census_places_file_path)
    end

    private

    def lookup_state_code(state_name)
      unless @states
        @states = {}
        foreach(data_file(USGeoData::STATES_FILE)) do |row|
          @states[row["Name"].upcase] = row["Code"]
        end
      end
      @states[state_name.upcase]
    end

    def county?(fips_class_code)
      FIPS_CLASSIFICATIONS[fips_class_code]&.include?(:county)
    end

    def subdivision?(fips_class_code)
      FIPS_CLASSIFICATIONS[fips_class_code]&.include?(:subdivision)
    end

    def place?(fips_class_code)
      FIPS_CLASSIFICATIONS[fips_class_code]&.include?(:place)
    end

    def non_census_place?(fips_class_code)
      FIPS_CLASSIFICATIONS[fips_class_code]&.include?(:non_census_place)
    end
  end
end
