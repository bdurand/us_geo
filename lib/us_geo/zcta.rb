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

    # @!method self.for_zipcode
    #   This scope will search for ZCTA's via the ZCTAMappings table. This is useful
    #   when you have a retired ZIP code and want to find the current ZCTA for that ZIP code.
    #
    #   @return [ActiveRecord::Relation] ZCTA's matching the given ZIP code.
    scope :for_zipcode, ->(zipcode) { left_outer_joins(:zcta_mappings).where(ZctaMapping.table_name => {zipcode: zipcode}).or(left_outer_joins(:zcta_mappings).where(zipcode: zipcode)).distinct }

    # @!method zcta_counties
    #   @return [ActiveRecord::Relation] ZCTA to county mappings.
    has_many :zcta_counties, -> { not_removed }, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy

    # @!method counties
    #   @return [ActiveRecord::Relation] Counties that this ZCTA is a part of.
    has_many :counties, -> { not_removed }, through: :zcta_counties

    # @!method primary_county
    #   @return [USGeo::County] County that contains most of the ZCTA's land area.
    belongs_to :primary_county, foreign_key: :primary_county_geoid, optional: true, class_name: "USGeo::County"

    # @!method zcta_urban_areas
    #   @return [ActiveRecord::Relation] ZCTA to urban area mappings.
    has_many :zcta_urban_areas, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy

    # @!method urban_areas
    #   @return [ActiveRecord::Relation] Urban areas that this ZCTA is a part of.
    has_many :urban_areas, through: :zcta_urban_areas

    # @!method primary_urban_area
    #   @return [USGeo::UrbanArea] Urban area that contains most of the ZCTA's land area.
    belongs_to :primary_urban_area, foreign_key: :primary_urban_area_geoid, optional: true, class_name: "USGeo::UrbanArea"

    # @!method zcta_county_subdivisions
    #   @return [ActiveRecord::Relation] ZCTA to county subdivision mappings.
    has_many :zcta_county_subdivisions, -> { not_removed }, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy

    # @!method county_subdivisions
    #   @return [ActiveRecord::Relation] County subdivisions that this ZCTA is a part of.
    has_many :county_subdivisions, -> { not_removed }, through: :zcta_county_subdivisions

    # @!method primary_county_subdivision
    #   @return [USGeo::CountySubdivision] County subdivision that contains most of the ZCTA's land area.
    belongs_to :primary_county_subdivision, foreign_key: :primary_county_subdivision_geoid, optional: true, class_name: "USGeo::CountySubdivision"

    # @!method zcta_places
    #   @return [ActiveRecord::Relation] ZCTA to place mappings.
    has_many :zcta_places, -> { not_removed }, foreign_key: :zipcode, inverse_of: :zcta, dependent: :destroy

    # @!method places
    #   @return [ActiveRecord::Relation] Places that this ZCTA is a part of.
    has_many :places, -> { not_removed }, through: :zcta_places

    # @!method primary_place
    #   @return [USGeo::Place] Place that contains most of the ZCTA's land area.
    belongs_to :primary_place, foreign_key: :primary_place_geoid, optional: true, class_name: "USGeo::Place"

    # @!method zcta_mappings
    #   @return [ActiveRecord::Relation] 2010 ZCTA to current ZCTA mappings.
    has_many :zcta_mappings, -> { not_removed }, foreign_key: :zcta_zipcode, inverse_of: :zcta, dependent: :destroy

    validates :zipcode, length: {is: 5}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true
    validates :population, numericality: {only_integer: true}, presence: true
    validates :housing_units, numericality: {only_integer: true}, presence: true

    # @!attribute zipcode
    #   @return [String] 5-digit ZIP code.

    # @!method combined_statistical_area
    #   @return [USGeo::CombinedStatisticalArea, nil] Combined statistical area that contains the ZCTA.
    delegate :combined_statistical_area, to: :primary_county, allow_nil: true

    # @!method core_based_statistical_area
    #   @return [USGeo::CoreBasedStatisticalArea, nil] Core-based statistical area that contains the ZCTA.
    delegate :core_based_statistical_area, to: :primary_county, allow_nil: true

    # @!method metropolitan_division
    #   @return [USGeo::MetropolitanDivision, nil] Metropolitan division that contains the ZCTA.
    delegate :metropolitan_division, to: :primary_county, allow_nil: true

    # @!method state
    #   @return [USGeo::State] State that contains the ZCTA.
    delegate :state, to: :primary_county, allow_nil: true

    # @!method state_code
    #   @return [String] State code that contains the ZCTA.
    delegate :state_code, to: :primary_county, allow_nil: true

    # @!method time_zone
    #   Get the time zone for the primary county containing the ZCTA. Note that this is not
    #   necessarily the time zone for the ZCTA itself since a handful of counties span multiple
    #   time zones.
    #   @return [ActiveSupport::TimeZone, nil] Time zone for the ZCTA.
    delegate :time_zone, to: :primary_county, allow_nil: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "zctas.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZCTA5"]) do |record|
              record.primary_county_geoid = row["Primary County"]
              record.primary_urban_area_geoid = row["Primary Urban Area"]
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
