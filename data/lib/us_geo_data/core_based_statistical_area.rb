# frozen_string_literal: true

module USGeoData
  class CoreBasedStatisticalArea
    include Processor

    def initialize(counties: nil)
      @counties = nil
    end

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "Name", "Short Name", "CSA", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      core_based_statistical_area_data.values.sort_by { |data| data[:geoid] }.each do |data|
        csv << [
          data[:geoid],
          data[:name],
          data[:short_name],
          data[:csa],
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

    def core_based_statistical_area_data
      unless defined?(@core_based_statistical_area_data)
        core_based_statistical_areas = {}
        foreach(data_file(USGeoData::CBSA_DELINEATION_FILE), col_sep: ",") do |row|
          cbsa_code = row["CBSA Code"]
          next if cbsa_code.to_s.empty?

          data = core_based_statistical_areas[cbsa_code]
          unless data
            data = {
              geoid: cbsa_code,
              name: row["CBSA Title"],
              short_name: short_name(row["CBSA Title"]),
              csa: row["CSA Code"],
              counties: Set.new,
              population: 0,
              housing_units: 0,
              land_area: 0.0,
              water_area: 0.0
            }
            core_based_statistical_areas[cbsa_code] = data
          end

          county_geoid = "#{row["FIPS State Code"]}#{row["FIPS County Code"]}"
          data[:counties] << county_geoid unless county_geoid.to_s.empty?
        end

        foreach(data_file(USGeoData::CBSA_GAZETTEER_FILE), col_sep: "|") do |row|
          cbsa_geoid = row["GEOID"]
          next if cbsa_geoid.to_s.empty?
          data = core_based_statistical_areas[cbsa_geoid]
          if data
            data[:lat] = row["INTPTLAT"]&.to_f
            data[:lng] = row["INTPTLONG"]&.to_f
            data[:land_area] = row["ALAND_SQMI"]&.to_f
            data[:water_area] = row["AWATER_SQMI"]&.to_f
          end
        end

        add_county_data(core_based_statistical_areas)

        @core_based_statistical_area_data = core_based_statistical_areas
      end
      @core_based_statistical_area_data
    end

    private

    def short_name(name)
      city, state = name.split(", ", 2)
      "#{city.split("-").first.split("/").first}, #{state.split("-").first}"
    end

    def add_county_data(core_based_statistical_areas)
      core_based_statistical_areas.each do |code, data|
        data[:counties].each do |county_geoid|
          county = county_data[county_geoid]
          data[:population] += county[:population]
          data[:housing_units] += county[:housing_units]
        end
      end
    end

    def county_data
      @counties ||= County.new
      @counties.county_data
    end
  end
end
