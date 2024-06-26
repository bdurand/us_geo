# frozen_string_literal: true

module USGeo
  # Division of very large metropolitian areas into groups of approximately 2.5 million people.
  class Place < BaseRecord
    include Population
    include Area

    self.primary_key = "geoid"

    # !@method zcta_places
    #   @return [ActiveRecord::Relation<ZctaPlace>] ZCTA to place mapping.
    has_many :zcta_places, -> { not_removed }, foreign_key: :place_geoid, inverse_of: :place, dependent: :destroy

    # !@method zctas
    #   @return [ActiveRecord::Relation<Zcta>] ZCTA's that overlap with this place.
    has_many :zctas, -> { not_removed }, through: :zcta_places

    # !@method place_counties
    #   @return [ActiveRecord::Relation<PlaceCounty>] Place to county mapping.
    has_many :place_counties, -> { not_removed }, foreign_key: :place_geoid, inverse_of: :place, dependent: :destroy

    # !@method counties
    #   @return [ActiveRecord::Relation<County>] Counties that this place is a part of.
    has_many :counties, -> { not_removed }, through: :place_counties

    # !@method primary_county
    #   @return [County] County that contains most of the place.
    belongs_to :primary_county, foreign_key: :primary_county_geoid, optional: true, class_name: "USGeo::County"

    # !@method urban_area
    #   @return [UrbanArea] Urban area that the place is a part of.
    belongs_to :urban_area, foreign_key: :urban_area_geoid, optional: true, class_name: "USGeo::UrbanArea"

    # !@method state
    #   @return [State] State that the place is in.
    belongs_to :state, foreign_key: :state_code, optional: true, inverse_of: :places

    validates :geoid, length: {is: 7}
    validates :state_code, length: {is: 2}
    validates :primary_county_geoid, length: {is: 5}
    validates :urban_area_geoid, length: {is: 5}, allow_nil: true
    validates :name, presence: true, length: {maximum: 60}
    validates :short_name, length: {maximum: 30}
    validates :fips_class_code, length: {is: 2}
    validates :land_area, numericality: true, allow_nil: true
    validates :water_area, numericality: true, allow_nil: true
    validates :population, numericality: {only_integer: true}, allow_nil: true
    validates :housing_units, numericality: {only_integer: true}, allow_nil: true

    # @!attribute geoid
    #   @return [String] 7-digit code for the place.

    # @!attribute name
    #   @return [String] Name of the place.

    # @!attribute short_name
    #   @return [String] Short name of the place.

    # @!attribute state_code
    #   @return [String] 2-letter code for the state.

    # @!attribute fips_class_code
    #   @return [String] 2-character FIPS class code.

    # @!method combined_statistical_area
    #   @return [CombinedStatisticalArea, nil] Combined statistical area that the place is a part of.
    delegate :combined_statistical_area, to: :primary_county, allow_nil: true

    # @!method core_based_statistical_area
    #   @return [CoreBasedStatisticalArea, nil] Core-based statistical area that the place is a part of.
    delegate :core_based_statistical_area, to: :primary_county, allow_nil: true

    # @!method metropolitan_division
    #   @return [MetropolitanDivision, nil] Metropolitan division that the place is a part of.
    delegate :metropolitan_division, to: :primary_county, allow_nil: true

    # Full name of the place as short name plus the state.
    #
    # @return [String]
    def full_name
      "#{short_name}, #{state_code}"
    end

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "places.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.gnis_id = row["GNIS ID"]
              record.name = row["Name"]
              record.short_name = row["Short Name"]
              record.state_code = row["State"]
              record.primary_county_geoid = row["County GEOID"]
              record.urban_area_geoid = row["Urban Area GEOID"]
              record.fips_class_code = row["FIPS Class"]
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
