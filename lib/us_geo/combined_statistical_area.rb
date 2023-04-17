# frozen_string_literal: true

module USGeo
  # Combined statistical area (CSA) of multiple metropolitan areas with weak regional
  # and economic connectoins between them.
  class CombinedStatisticalArea < BaseRecord
    include Population
    include Area

    self.primary_key = "geoid"

    has_many :core_based_statistical_areas, foreign_key: :csa_geoid, inverse_of: :combined_statistical_area

    validates :geoid, length: {is: 3}
    validates :name, presence: true, length: {maximum: 60}, uniqueness: true
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true
    validates :population, numericality: {only_integer: true}, presence: true
    validates :housing_units, numericality: {only_integer: true}, presence: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "combined_statistical_areas.csv")
        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.name = row["Name"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
            end
          end
        end
      end
    end
  end
end
