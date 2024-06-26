# frozen_string_literal: true

module USGeo
  # County or county equivalent. Counties are composed of zero or more ZCTA's and may
  # belong to a CBSA. The county's significance withing the CBSA is indicated by the
  # central flag which indicates if it is a central or outlying county.
  class County < BaseRecord
    include Population
    include Area

    self.primary_key = "geoid"

    belongs_to :core_based_statistical_area, foreign_key: :cbsa_geoid, optional: true, inverse_of: :counties
    belongs_to :metropolitan_division, foreign_key: :metropolitan_division_geoid, optional: true, inverse_of: :counties
    belongs_to :state, foreign_key: :state_code, optional: true, inverse_of: :counties

    has_many :subdivisions, -> { not_removed }, foreign_key: :county_geoid, inverse_of: :county, class_name: "USGeo::CountySubdivision"

    has_many :zcta_counties, -> { not_removed }, foreign_key: :county_geoid, inverse_of: :county, dependent: :destroy
    has_many :zctas, -> { not_removed }, through: :zcta_counties

    has_many :urban_area_counties, foreign_key: :county_geoid, inverse_of: :county, dependent: :destroy
    has_many :urban_areas, through: :urban_area_counties

    has_many :place_counties, -> { not_removed }, foreign_key: :county_geoid, inverse_of: :county, dependent: :destroy
    has_many :places, -> { not_removed }, through: :place_counties

    validates :geoid, length: {is: 5}
    validates :name, presence: true, length: {maximum: 60}, uniqueness: {scope: :state_code}
    validates :short_name, presence: true, length: {maximum: 30}, uniqueness: {scope: :state_code}
    validates :state_code, length: {is: 2}
    validates :fips_class_code, length: {is: 2}
    validates :metropolitan_division_geoid, length: {is: 5}, allow_nil: true
    validates :cbsa_geoid, length: {is: 5}, allow_nil: true
    validates :land_area, numericality: true, allow_nil: true
    validates :water_area, numericality: true, allow_nil: true
    validates :population, numericality: {only_integer: true}, allow_nil: true
    validates :housing_units, numericality: {only_integer: true}, allow_nil: true

    # @!attribute geoid
    #   @return [String] 5-digit code for the county.

    # @!attribute name
    #   @return [String] Name of the county.

    # @!attribute short_name
    #   @return [String] Short name of the county.

    # @!attribute state_code
    #   @return [String] 2-letter code for the state.

    # @!attribute fips_class_code
    #   @return [String] 2-character FIPS class code.

    # @!attribute time_zone_name
    #   @return [String] Time zone name.

    # @!attribute time_zone_2_name
    #   @return [String] Time zone name.

    # @!method central?
    #   @return [Boolean] True if the county is a central county in the CBSA.

    # @!method combined_statistical_area
    #   @return [USGeo::CombinedStatisticalArea] Combined statistical area that the county belongs to.
    delegate :combined_statistical_area, to: :core_based_statistical_area, allow_nil: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "counties.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.gnis_id = row["GNIS ID"]
              record.name = row["Name"]
              record.short_name = row["Short Name"]
              record.state_code = row["State"]
              record.cbsa_geoid = row["CBSA"]
              record.metropolitan_division_geoid = row["Metropolitan Division"]
              record.time_zone_name = row["Time Zone"]
              record.time_zone_2_name = row["Time Zone 2"]
              record.fips_class_code = row["FIPS Class"]
              record.central = (row["Central"] == "T")
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

    # Full name of the county with the state.
    #
    # @return [String]
    def full_name
      "#{name}, #{state_code}"
    end

    def state_fips
      geoid[0, 2]
    end

    def county_fips
      geoid[2, 3]
    end

    # Return the CBSA only if it is a metropolitan area.
    def metropolitan_area
      core_based_statistical_area if core_based_statistical_area&.metropolitan?
    end

    # Return a single time zone for the county. If the county has two time zones,
    # only one is returned.
    #
    # @return [ActiveSupport::TimeZone, nil]
    def time_zone
      ActiveSupport::TimeZone[time_zone_name] if time_zone_name
    end

    # Get all time zones for the county.
    #
    # @return [Array<ActiveSupport::TimeZone>]
    def time_zones
      [time_zone_name, time_zone_2_name].compact.collect do |tz_name|
        ActiveSupport::TimeZone[tz_name]
      end.compact
    end

    # True if the county is an outlying county in the CBSA.
    #
    # @return [Boolean]
    def outlying?
      !central?
    end
  end
end
