# frozen_string_literal: true

module USGeo
  # U.S. region.
  class Region < BaseRecord
    include Population
    include Area

    has_many :divisions, inverse_of: :region
    has_many :states, inverse_of: :region

    validates :name, presence: true, length: {maximum: 30}, uniqueness: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "regions.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(id: row["ID"]) do |record|
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
