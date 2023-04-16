# frozen_string_literal: true

module USGeoData
  class CombinedStatisticalArea
    include Processor

    def initialize(counties: nil)
      @counties = nil
    end

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "Name", "Population", "Housing Units", "Land Area", "Water Area"]
      combined_statistical_area_data.each do |geoid, data|
        csv << [
          geoid,
          data[:name],
          data[:population],
          data[:housing_units],
          data[:land_area]&.round(3),
          data[:water_area]&.round(3)
        ]
      end
      output
    end

    def combined_statistical_area_data
      unless defined?(@combined_statistical_area_data)
        combined_statistical_areas = {}

        foreach(data_file(USGeoData::CBSA_DELINEATION_FILE), col_sep: ",") do |row|
          csa_code = row["CSA Code"]
          next if csa_code.nil? || csa_code.empty?

          data = combined_statistical_areas[csa_code]
          unless data
            data = {name: row["CSA Title"], counties: Set.new, population: 0, housing_units: 0, land_area: 0.0, water_area: 0.0}
            combined_statistical_areas[csa_code] = data
          end

          county_geoid = "#{row["FIPS State Code"]}#{row["FIPS County Code"]}"
          data[:counties] << county_geoid
        end

        add_county_data(combined_statistical_areas)

        @combined_statistical_area_data = combined_statistical_areas
      end
      @combined_statistical_area_data
    end

    private

    def add_county_data(combined_statistical_areas)
      combined_statistical_areas.each do |code, data|
        data[:counties].each do |county_geoid|
          county = county_data[county_geoid]
          data[:population] += county[:population].to_i
          data[:housing_units] += county[:housing_units].to_i
          data[:land_area] += county[:land_area].to_f
          data[:water_area] += county[:water_area].to_f
        end
      end
    end

    def county_data
      @counties ||= County.new
      @counties.county_data
    end
  end
end
