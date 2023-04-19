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
  # ZCTA's can span places, but the one with the majority of the residents is identified
  # as the primary place for when a single area is required.
  class Zcta < BaseRecord
    include Population
    include Area

    self.table_name = "us_geo_zctas"
    self.primary_key = "zipcode"
    self.ignored_columns = %w[primary_urban_area_geoid]

    # This scope will search for ZCTA's via the ZCTAMappings table. This is useful
    # when you have a retired ZIP code and want to find the current ZCTA for that ZIP code.
    scope :for_zipcode, ->(zipcode) { left_outer_joins(:zcta_mappings).where(ZctaMapping.table_name => {zipcode: zipcode}).or(left_outer_joins(:zcta_mappings).where(zipcode: zipcode)).distinct }

    has_many :zcta_counties, -> { not_removed }, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy
    has_many :counties, -> { not_removed }, through: :zcta_counties
    belongs_to :primary_county, foreign_key: :primary_county_geoid, class_name: "USGeo::County"

    has_many :zcta_county_subdivisions, -> { not_removed }, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy
    has_many :county_subdivisions, -> { not_removed }, through: :zcta_county_subdivisions
    belongs_to :primary_county_subdivision, foreign_key: :primary_county_subdivision_geoid, class_name: "USGeo::CountySubdivision"

    has_many :zcta_places, -> { not_removed }, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy
    has_many :places, -> { not_removed }, through: :zcta_places
    belongs_to :primary_place, foreign_key: :primary_place_geoid, class_name: "USGeo::Place"

    has_many :zcta_mappings, -> { not_removed }, foreign_key: :zcta_zipcode, inverse_of: :zcta, dependent: :destroy

    validates :zipcode, length: {is: 5}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true
    validates :population, numericality: {only_integer: true}, presence: true
    validates :housing_units, numericality: {only_integer: true}, presence: true

    delegate :core_based_statistical_area,
      :combined_statistical_area,
      :metropolitan_division,
      :designated_market_area,
      :state,
      :state_code,
      :time_zone_name,
      :time_zone,
      to: :primary_county,
      allow_nil: true

    # @!attribute zipcode
    #   @return [String] 5-digit ZIP code.

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "zctas.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZCTA5"]) do |record|
              record.primary_county_geoid = row["Primary County"]
              record.primary_county_subdivision_geoid = row["Primary County Subdivision"]
              record.primary_place_geoid = row["Primary Place"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
              record.lat = row["Latitude"]
              record.lng = row["Longitude"]
            end
          end
        end
      end
    end
  end
end
