# frozen_string_literal: true

module USGeo
  # U.S. regional division composed of states.
  class Division < BaseRecord
    include Population
    include Area

    belongs_to :region, inverse_of: :divisions
    has_many :states, inverse_of: :division

    validates :name, presence: true, length: {maximum: 30}, uniqueness: true

    # @!attribute id
    #   @return [Integer] ID of the division.

    # @!attribute name
    #   @return [String] Name of the division.

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "divisions.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(id: row["ID"]) do |record|
              record.name = row["Name"]
              record.region_id = row["Region ID"]
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
