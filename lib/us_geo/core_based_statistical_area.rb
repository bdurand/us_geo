# frozen_string_literal: true

module USGeo

  # Core based statistical area composed of one or more counties anchored by an urban center.
  # Includes both metropolitan (population > 50,000) and micropolitan (population > 10,000
  # but < 50,000) areas.
  class CoreBasedStatisticalArea < BaseRecord

    include Demographics

    self.primary_key = "geoid"
    self.store_full_sti_class = false

    has_many :counties, foreign_key: :cbsa_geoid, inverse_of: :core_based_statistical_area
    has_many :metropolitan_divisions, foreign_key: :cbsa_geoid, inverse_of: :core_based_statistical_area
    belongs_to :combined_statistical_area, foreign_key: :csa_geoid, optional: true, inverse_of: :core_based_statistical_areas

    validates :geoid, length: {is: 5}
    validates :name, length: {maximum: 60}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true
    validates :population, numericality: {only_integer: true}, presence: true
    validates :housing_units, numericality: {only_integer: true}, presence: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "core_based_statistical_areas.csv.gz")
        
        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.type = (row["Population"].to_i >= 50_000 ? "MetropolitanArea" : "MicropolitanArea")
              record.name = row["Name"]
              record.csa_geoid = row["CSA"]
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

    def metropolitan?
      raise NotImplementedError
    end
    
    def micropolitan?
      raise NotImplementedError
    end

  end
end
