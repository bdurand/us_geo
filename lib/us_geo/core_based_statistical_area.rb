# frozen_string_literal: true

module USGeo
  # Core based statistical area composed of one or more counties anchored by an urban center.
  # Includes both metropolitan (population > 50,000) and micropolitan (population > 10,000
  # but < 50,000) areas.
  class CoreBasedStatisticalArea < BaseRecord
    include Population
    include Area

    self.primary_key = "geoid"
    self.store_full_sti_class = false

    has_many :counties, -> { not_removed }, foreign_key: :cbsa_geoid, inverse_of: :core_based_statistical_area
    has_many :metropolitan_divisions, -> { not_removed }, foreign_key: :cbsa_geoid, inverse_of: :core_based_statistical_area
    has_many :zctas, -> { not_removed }, through: :counties
    has_many :places, -> { not_removed }, through: :counties

    belongs_to :combined_statistical_area, foreign_key: :csa_geoid, optional: true, inverse_of: :core_based_statistical_areas

    validates :geoid, length: {is: 5}
    validates :name, presence: true, length: {maximum: 60}, uniqueness: true
    validates :short_name, presence: true, length: {maximum: 60}, uniqueness: true
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true
    validates :population, numericality: {only_integer: true}, presence: true
    validates :housing_units, numericality: {only_integer: true}, presence: true

    # @!attribute geoid
    #   @return [String] 5-digit code for the CBSA.

    # @!attribute name
    #   @return [String] Name of the CBSA.

    # @!attribute short_name
    #   @return [String] Short name of the CBSA.

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "core_based_statistical_areas.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.type = ((row["Population"].to_i >= 50_000) ? "MetropolitanArea" : "MicropolitanArea")
              record.name = row["Name"]
              record.short_name = row["Short Name"]
              record.csa_geoid = row["CSA"]
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

    def metropolitan?
      raise NotImplementedError
    end

    def micropolitan?
      raise NotImplementedError
    end
  end
end
