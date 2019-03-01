# frozen_string_literal: true

module USGeo

  # U.S. state or territory.
  class State < BaseRecord

    STATE_TYPE = "state"
    DISTRICT_TYPE = "district"
    TERRITORY_TYPE = "territory"
    
    self.primary_key = "code"
    self.inheritance_column = :_type_disabled

    belongs_to :region, optional: -> { territory? }, inverse_of: :states
    belongs_to :division, optional: -> { territory? }, inverse_of: :states
    has_many :counties, foreign_key: :state_code, inverse_of: :state

    validates :code, length: {is: 2}
    validates :fips, length: {is: 2}
    validates :name, length: {maximum: 30}
    validates :type, inclusion: [STATE_TYPE, DISTRICT_TYPE, TERRITORY_TYPE]

    class << self
      def load!(location = nil)
        location ||= "#{BaseRecord::BASE_DATA_URI}/states.csv"
        mark_removed! do
          load_data_file(location) do |row|
            load_record!(code: row["Code"]) do |record|
              record.name = row["Name"]
              record.type = row["Type"]
              record.fips = row["FIPS"]
              record.region_id = row["Region ID"]
              record.division_id = row["Division ID"]
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
