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
      def load!(location = nil)
        location ||= "#{BaseRecord::BASE_DATA_URI}/zcta_urban_areas.csv.gz"
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

    # Percentage of the ZCTA population in the urban area.
    def percent_population
      population.to_f / zcta.population.to_f
    end

    # Percentage of the ZCTA land area in the urban area.
    def percent_land_area
      land_area / zcta.land_area
    end

    # Percentage of the ZCTA total area in the urban area.
    def percent_total_area
      total_area / zcta.total_area
    end

  end
end
