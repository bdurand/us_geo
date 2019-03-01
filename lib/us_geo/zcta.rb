# frozen_string_literal: true

module USGeo

  # ZIP code tabulation area. These roughly map to U.S. Postal service ZIP codes, but
  # are designed for geographic and demographic purposes instead of mail routing. In particular
  # certain optimizations that the Postal Service makes to optimize mail routing are
  # omitted or smoothed over (i.e. ZIP codes mapping to a single building, one-off enclaves, etc.)
  #
  # ZCTA's can span counties, but the one with the majority of the residents is identified
  # as the primary county for when a single county is required.
  #
  # ZCTA's can span urbanized area, but the one with the majority of the residents is identified
  # as the primary urbanized area for when a single area is required.
  class Zcta < BaseRecord

    include Demographics

    self.table_name = "us_geo_zctas"
    self.primary_key = "zipcode"

    has_many :zcta_counties, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy
    has_many :counties, through: :zcta_counties
    belongs_to :primary_county, foreign_key: :primary_county_geoid, class_name: "USGeo::County"

    has_many :zcta_urban_areas, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy
    has_many :urban_areas, through: :zcta_urban_areas
    belongs_to :primary_urban_area, foreign_key: :primary_urban_area_geoid, class_name: "USGeo::UrbanArea"

    validates :zipcode, length: {is: 5}

    delegate :core_based_statistical_area, :designated_market_area, :state, :state_code, :time_zone, to: :primary_county, allow_nil: true

    class << self
      def load!(location = nil)
        location ||= "#{BaseRecord::BASE_DATA_URI}/zctas.csv.gz"
        mark_removed! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZCTA5"]) do |record|
              record.primary_county_geoid = row["Primary County"]
              record.primary_urban_area_geoid = row["Primary Urban Area"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = area_meters_to_miles(row["Land Area"])
              record.water_area = area_meters_to_miles(row["Water Area"])
              record.lat = row["Latitude"]
              record.lng = row["Longitude"]
            end
          end
        end
      end
    end

  end
end
