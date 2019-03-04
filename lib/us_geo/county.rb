# frozen_string_literal: true

module USGeo

  # County or county equivalent. Counties are composed of zero or more ZCTA's and may
  # belong to a CBSA. The county's significance withing the CBSA is indicated by the
  # central flag which indicates if it is a central or outlying county.
  class County < BaseRecord

    include Demographics

    self.primary_key = "geoid"

    belongs_to :designated_market_area, foreign_key: :dma_code, optional: true, inverse_of: :counties
    belongs_to :core_based_statistical_area, foreign_key: :cbsa_geoid, optional: true, inverse_of: :counties
    belongs_to :metropolitan_division, foreign_key: :metropolitan_division_geoid, optional: true, inverse_of: :counties
    belongs_to :state, foreign_key: :state_code, inverse_of: :counties

    has_many :subdivisions, foreign_key: :county_geoid, inverse_of: :county, class_name: "USGeo::CountySubdivision"

    has_many :zcta_counties, foreign_key: :county_geoid, inverse_of: :county, dependent: :destroy
    has_many :zctas, through: :zcta_counties

    has_many :urban_area_counties, foreign_key: :county_geoid, inverse_of: :county, dependent: :destroy
    has_many :urban_areas, through: :urban_area_counties

    has_many :place_counties, foreign_key: :county_geoid, inverse_of: :county, dependent: :destroy
    has_many :places, through: :place_counties

    validates :geoid, length: {is: 5}
    validates :name, length: {maximum: 60}
    validates :short_name, length: {maximum: 30}
    validates :state_code, length: {is: 2}
    validates :fips_class_code, length: {is: 2}
    validates :metropolitan_division_geoid, length: {is: 5}, allow_nil: true
    validates :cbsa_geoid, length: {is: 5}, allow_nil: true
    validates :dma_code, length: {is: 3}, allow_nil: true
    validates :land_area, numericality: true, allow_nil: true
    validates :water_area, numericality: true, allow_nil: true
    validates :population, numericality: {only_integer: true}, allow_nil: true
    validates :housing_units, numericality: {only_integer: true}, allow_nil: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "counties.csv.gz")

        mark_removed! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.gnis_id = row["GNIS ID"]
              record.name = row["Name"]
              record.short_name = row["Short Name"]
              record.state_code = row["State"]
              record.cbsa_geoid = row["CBSA"]
              record.dma_code = row["DMA"]
              record.time_zone_name = row["Time Zone"]
              record.fips_class_code = row["FIPS Class"]
              record.central = (row["Central"] == "T")
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

    def state_fips
      geoid[0, 2]
    end

    def county_fips
      geoid[2, 3]
    end

    # Return the CBSA only if it is a metropolitan area.
    def metropolitan_area
      core_based_statistical_area if core_based_statistical_area && core_based_statistical_area.metropolitan?
    end

    def time_zone
      ActiveSupport::TimeZone[time_zone_name] if time_zone_name
    end

  end
end
