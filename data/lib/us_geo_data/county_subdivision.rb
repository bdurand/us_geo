# frozen_string_literal: true

module USGeoData
  class CountySubdivision
    include Processor

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "GNIS ID", "Name", "County GEOID", "FIPS Class", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      subdivision_data.each do |geoid, data|
        unless data[:gnis_id] && data[:fips_class]
          puts "Missing data for subdivision #{data[:geoid]} #{data[:name]}: #{data.inspect}"
          next
        end
        csv << [
          data[:geoid],
          data[:gnis_id],
          data[:name],
          data[:county_geoid],
          data[:fips_class],
          data[:population],
          data[:housing_units],
          data[:land_area]&.round(3),
          data[:water_area]&.round(3),
          data[:lat],
          data[:lng]
        ]
      end
      output
    end

    def subdivision_data
      unless defined?(@subdivision_data)
        gnis_subdivisions = gnis_subdivision_mapping

        subdivisions = {}
        foreach(data_file(USGeoData::SUBDIVISION_GAZETTEER_FILE), col_sep: "|") do |row|
          geoid = row["GEOID"]
          gnis_id = row["ANSICODE"].gsub(/\A0+/, "").to_i
          data = gnis_subdivisions[gnis_id]
          next unless data && geoid.start_with?(data[:county_geoid])

          data[:geoid] = geoid
          data[:land_area] = row["ALAND_SQMI"]&.to_f
          data[:water_area] = row["AWATER_SQMI"]&.to_f
          subdivisions[geoid] = data
        end

        add_demographics(subdivisions, USGeoData::COUNTY_SUBDIVISION_DEMOGRAPHICS_FILE, ["state", "county", "county subdivision"])

        @subdivision_data = subdivisions
      end
      @subdivision_data
    end

    private

    def gnis_subdivision_mapping
      gnis_subdivisions = {}
      foreach(processed_file(Gnis::SUBDIVISIONS_FILE), col_sep: ",") do |row|
        gnis_id = row["GNIS ID"].to_i
        gnis_subdivisions[gnis_id] = {
          gnis_id: gnis_id,
          fips_class: row["FIPS Class"],
          name: row["Name"],
          county_geoid: row["County GEOID"],
          lat: row["Latitude"].to_f,
          lng: row["Longitude"].to_f
        }
      end
      gnis_subdivisions
    end
  end
end
