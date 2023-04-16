# frozen_string_literal: true

module USGeoData
  class MetropolitanDivision
    include Processor

    def initialize(counties: nil)
      @counties = nil
    end

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "Name", "CBSA", "Population", "Housing Units", "Land Area", "Water Area"]
      metropolitan_division_data.each do |geoid, data|
        csv << [geoid, data[:name], data[:cbsa], data[:population], data[:housing_units], data[:land_area]&.round(3), data[:water_area]&.round(3)]
      end
      output
    end

    def metropolitan_division_data
      unless defined?(@metropolitan_division_data)
        metropolitan_divisions = {}

        foreach(data_file(USGeoData::CBSA_DELINEATION_FILE), col_sep: ",") do |row|
          division_code = row["Metropolitan Division Code"]
          next if division_code.nil? || division_code.empty?

          data = metropolitan_divisions[division_code]
          unless data
            data = {
              geoid: division_code,
              name: row["Metropolitan Division Title"],
              counties: [],
              population: 0,
              housing_units: 0,
              land_area: 0.0,
              water_area: 0.0
            }
            data[:cbsa] = row["CBSA Code"]
            metropolitan_divisions[division_code] = data
          end

          county_geoid = "#{row["FIPS State Code"]}#{row["FIPS County Code"]}"
          data[:counties] << county_geoid unless data[:counties].include?(county_geoid)
        end

        add_county_data(metropolitan_divisions)

        @metropolitan_division_data = metropolitan_divisions
      end
    end

    private

    def add_county_data(metropolitan_divisions)
      metropolitan_divisions.each do |code, data|
        data[:counties].each do |county_geoid|
          county = county_data[county_geoid]
          data[:population] += county[:population]
          data[:housing_units] += county[:housing_units]
          data[:land_area] += county[:land_area]
          data[:water_area] += county[:water_area]
        end
      end
    end

    def county_data
      @counties ||= County.new
      @counties.county_data
    end
  end
end
