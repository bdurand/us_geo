# frozen_string_literal: true

module USGeo
  # U.S. state or territory.
  class State < BaseRecord
    include Population
    include Area

    STATE_TYPE = "state"
    DISTRICT_TYPE = "district"
    TERRITORY_TYPE = "territory"

    self.primary_key = "code"
    self.inheritance_column = :_type_disabled

    belongs_to :region, optional: -> { territory? }, inverse_of: :states
    belongs_to :division, optional: -> { territory? }, inverse_of: :states

    delegate :region, to: :division, allow_nil: true

    has_many :counties, -> { not_removed }, foreign_key: :state_code, inverse_of: :state
    has_many :places, -> { not_removed }, foreign_key: :state_code, inverse_of: :state

    validates :code, length: {is: 2}, uniqueness: true
    validates :fips, length: {is: 2}
    validates :name, presence: true, length: {maximum: 30}, uniqueness: true
    validates :type, inclusion: [STATE_TYPE, DISTRICT_TYPE, TERRITORY_TYPE]

    # @!attribute code
    #   @return [String] 2-letter postal code of the state.

    # @!attribute name
    #   @return [String] Name of the state.

    # @!attribute fips
    #   @return [String] 2-digit FIPS code of the state.

    # @!attribute type
    #   @return [String] Type of the state or territory.

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "states.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(code: row["Code"]) do |record|
              record.name = row["Name"]
              record.type = row["Type"]
              record.fips = row["FIPS"]
              record.region_id = row["Region ID"]
              record.division_id = row["Division ID"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
            end
          end
        end
      end
    end

    def state?
      type == STATE_TYPE
    end

    def territory?
      type == TERRITORY_TYPE
    end

    def district?
      type == DISTRICT_TYPE
    end
  end
end
