# frozen_string_literal: true

module USGeo
  # County subdivision.
  class CountySubdivision < BaseRecord
    include Population
    include Area

    self.primary_key = "geoid"

    belongs_to :county, foreign_key: :county_geoid, inverse_of: :subdivisions

    has_many :zcta_county_subdivisions, -> { not_removed }, foreign_key: :county_subdivision_geoid, inverse_of: :county_subdivision, dependent: :destroy
    has_many :zctas, -> { not_removed }, through: :zcta_county_subdivisions

    has_many :urban_area_county_subdivisions, foreign_key: :county_subdivision_geoid, inverse_of: :county_subdivision, dependent: :destroy
    has_many :urban_areas, through: :urban_area_county_subdivisions

    validates :geoid, length: {is: 10}
    validates :name, presence: true, length: {maximum: 60}, uniqueness: {scope: :county_geoid}
    validates :fips_class_code, length: {is: 2}
    validates :land_area, numericality: true, allow_nil: true
    validates :water_area, numericality: true, allow_nil: true
    validates :population, numericality: {only_integer: true}, allow_nil: true
    validates :housing_units, numericality: {only_integer: true}, allow_nil: true

    # @!attribute geoid
    #   @return [String] 10-digit code for the subdivision.

    # @!attribute name
    #   @return [String] Name of the subdivision.

    # @!attribute fips_class_code
    #   @return [String] 2-character FIPS class code.

    # @!method :core_based_statistical_area
    #   @return [CoreBasedStatisticalArea] Core-based statistical area the subdivision is in.
    delegate :core_based_statistical_area, to: :county

    # @!method :combined_statistical_area
    #   @return [CombinedStatisticalArea] Combined statistical area the subdivision is in.
    delegate :combined_statistical_area, to: :county

    # @!method :metropolitan_division
    #   @return [MetropolitanDivision] Metropolitan division the subdivision is in.
    delegate :metropolitan_division, to: :county

    # @!method :state
    #   @return [State] State the subdivision is in.
    delegate :state, to: :county

    # @!method :state_code
    #   @return [String] 2-character state code.
    delegate :state_code, to: :county

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "county_subdivisions.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.gnis_id = row["GNIS ID"]
              record.county_geoid = row["County GEOID"]
              record.name = row["Name"]
              record.fips_class_code = row["FIPS Class"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
              record.lat = row["Latitude"]
              record.lng = row["Longitude"]

              duplicate = where.not(geoid: record.geoid).find_by(name: record.name, county_geoid: record.county_geoid)
              duplicate&.update!(name: "#{record.name} (deleted)", status: BaseRecord::STATUS_REMOVED)
            end
          end
        end
      end
    end
  end
end
