# frozen_string_literal: true

module USGeo

  # Mapping of ZCTA's to urban areas they overlap with.
  class ZctaUrbanArea < BaseRecord

    include Demographics

    belongs_to :zcta, foreign_key: :zipcode, inverse_of: :zcta_urban_areas
    belongs_to :urban_area, foreign_key: :urban_area_geoid, inverse_of: :zcta_urban_areas

    validates :zipcode, length: {is: 5}
    validates :urban_area_geoid, length: {is: 5}

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "zcta_urban_areas.csv.gz")

        mark_removed! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZCTA5"], urban_area_geoid: row["Urban Area GEOID"]) do |record|
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = area_meters_to_miles(row["Land Area"])
              record.water_area = area_meters_to_miles(row["Water Area"])
            end
          end
        end
      end
    end

    # Percentage of the ZCTA population.
    def percent_zcta_population
      population.to_f / zcta.population.to_f
    end

    # Percentage of the ZCTA land area.
    def percent_zcta_land_area
      land_area / zcta.land_area
    end

    # Percentage of the ZCTA total area.
    def percent_zcta_total_area
      total_area / zcta.total_area
    end

    # Percentage of the urban area population.
    def percent_urban_area_population
      population.to_f / urban_area.population.to_f
    end

    # Percentage of the urban area land area.
    def percent_urban_area_land_area
      land_area / urban_area.land_area
    end

    # Percentage of the urban area total area.
    def percent_urban_area_total_area
      total_area / urban_area.total_area
    end

  end
end
