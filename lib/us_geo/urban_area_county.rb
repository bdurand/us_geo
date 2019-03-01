# frozen_string_literal: true

module USGeo

  # Mapping of urban areas to counties they overlap with.
  class UrbanAreaCounty < BaseRecord

    include Demographics

    belongs_to :county, foreign_key: :county_geoid, inverse_of: :urban_area_counties
    belongs_to :urban_area, foreign_key: :urban_area_geoid, inverse_of: :urban_area_counties

    validates :county_geoid, length: {is: 5}
    validates :urban_area_geoid, length: {is: 5}

    class << self
      def load!(location = nil)
        location ||= "#{BaseRecord::BASE_DATA_URI}/urban_area_counties.csv.gz"
        delete_unmodified! do
          load_data_file(location) do |row|
            load_record!(urban_area_geoid: row["Urban Area GEOID"], county_geoid: row["County GEOID"]) do |record|
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = area_meters_to_miles(row["Land Area"])
              record.water_area = area_meters_to_miles(row["Water Area"])
            end
          end
        end
      end
    end

    # Percentage of the urban area population in the county.
    def percent_population
      population.to_f / urban_area.population.to_f
    end

    # Percentage of the urban area land area in the county.
    def percent_land_area
      land_area / urban_area.land_area
    end

    # Percentage of the urban area total area in the county.
    def percent_total_area
      total_area / urban_area.total_area
    end

  end
end
