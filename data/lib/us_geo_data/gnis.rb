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
      "C7" => [:place, :subdivision],
      "M1" => [:place],
      "M2" => [:place],
      "U1" => [:place],
      "U2" => [:place],
      "H1" => [:county],
      "H4" => [:county],
      "H5" => [:county],
      "H6" => [:county],
      "T1" => [:subdivision],
      "T2" => [:subdivision],
      "T5" => [:subdivision],
      "T9" => [:subdivision],
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
      counties_file = File.open(processed_file(COUNTIES_FILE), "w")
      subdivisions_file = File.open(processed_file(SUBDIVISIONS_FILE), "w")
      places_file = File.open(processed_file(PLACES_FILE), "w")
      place_counties_file = File.open(processed_file(PLACE_COUNTIES_FILE), "w")

      begin
        counties_csv = CSV.new(counties_file)
        subdivisions_csv = CSV.new(subdivisions_file)
        places_csv = CSV.new(places_file)
        place_counties_csv = CSV.new(place_counties_file)

        counties_csv << ["GNIS ID", "GEOID", "Name", "Short Name", "State", "FIPS Class", "Latitude", "Longitude"]
        subdivisions_csv << ["GNIS ID", "GEOID", "Name", "State", "FIPS Class", "County GEOID", "Latitude", "Longitude"]
        places_csv << ["GNIS ID", "GEOID", "Name", "State", "FIPS Class", "County GEOID", "Latitude", "Longitude"]
        place_counties_csv << ["Place GEOID", "County GEOID"]

        foreach(data_file(USGeoData::GNIS_DATA_FILE), col_sep: "|", quote_char: nil) do |row|
          fips_class_code = row["CENSUS_CLASS_CODE"]
          gnis_id = row["FEATURE_ID"].to_i
          name = row["FEATURE_NAME"]
          state_fips = row["STATE_NUMERIC"]
          state_code = row["STATE_ALPHA"]
          geoid = "#{state_fips}#{row["CENSUS_CODE"]}"
          county_geoid = "#{state_fips}#{row["COUNTY_NUMERIC"]}"
          lat = row["PRIMARY_LATITUDE"]
          lng = row["PRIMARY_LONGITUDE"]
          county_num = row["COUNTY_SEQUENCE"].to_i

          if county?(fips_class_code)
            county_name = row["COUNTY_NAME"].to_s
            county_name = name if county_name.empty?
            counties_csv << [gnis_id, county_geoid, name, county_name, state_code, fips_class_code, lat, lng]
          end

          if subdivision?(fips_class_code) && county_num == 1
            geoid = "#{state_fips}#{row["COUNTY_NUMERIC"]}#{row["CENSUS_CODE"]}"
            subdivisions_csv << [gnis_id, geoid, name, state_code, fips_class_code, county_geoid, lat, lng]
          end

          if place?(fips_class_code)
            if county_num == 1
              places_csv << [gnis_id, geoid, name, state_code, fips_class_code, county_geoid, lat, lng]
            end
            place_counties_csv << [geoid, county_geoid]
          end
        end
      ensure
        counties_file.close
        subdivisions_file.close
        places_file.close
        place_counties_file.close
      end
    end

    private

    def county?(fips_class_code)
      FIPS_CLASSIFICATIONS[fips_class_code]&.include?(:county)
    end

    def subdivision?(fips_class_code)
      FIPS_CLASSIFICATIONS[fips_class_code]&.include?(:subdivision)
    end

    def place?(fips_class_code)
      FIPS_CLASSIFICATIONS[fips_class_code]&.include?(:place)
    end
  end
end
