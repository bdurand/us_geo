# frozen_string_literal: true

module USGeo

  # Mapping of ZCTA's to counties they overlap with.
  class ZctaCounty < BaseRecord

    include Demographics

    belongs_to :zcta, foreign_key: :zipcode, inverse_of: :zcta_counties
    belongs_to :county, foreign_key: :county_geoid, inverse_of: :zcta_counties

    validates :zipcode, length: {is: 5}
    validates :county_geoid, length: {is: 5}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true
    validates :population, numericality: {only_integer: true}, presence: true
    validates :housing_units, numericality: {only_integer: true}, presence: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "zcta_counties.csv")
        
        import! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZCTA5"], county_geoid: row["GEOID"]) do |record|
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

    # Percentage of the county population.
    def percent_county_population
      population.to_f / county.population.to_f
    end

    # Percentage of the county land area.
    def percent_county_land_area
      land_area / county.land_area
    end

    # Percentage of the county total area.
    def percent_county_total_area
      total_area / county.total_area
    end

  end
end
