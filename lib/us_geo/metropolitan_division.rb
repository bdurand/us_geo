# frozen_string_literal: true

module USGeo

  # Division of very large metropolitian areas into groups of approximately 2.5 million people.
  class MetropolitanDivision < BaseRecord

    include Demographics

    self.primary_key = "geoid"

    has_many :counties, foreign_key: :metropolitan_division_geoid, inverse_of: :metropolitan_division
    belongs_to :core_based_statistical_area, foreign_key: :cbsa_geoid, optional: true, inverse_of: :metropolitan_divisions

    validates :geoid, length: {is: 5}
    validates :name, length: {maximum: 60}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true
    validates :population, numericality: {only_integer: true}, presence: true
    validates :housing_units, numericality: {only_integer: true},  presence: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "metropolitan_divisions.csv.gz")

        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.name = row["Name"]
              record.cbsa_geoid = row["CBSA"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = area_meters_to_miles(row["Land Area"])
              record.water_area = area_meters_to_miles(row["Water Area"])
            end
          end
        end
      end
    end

  end
end
