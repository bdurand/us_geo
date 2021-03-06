# frozen_string_literal: true

module USGeo

  # U.S. regional division composed of states.
  class Division < BaseRecord

    belongs_to :region, inverse_of: :divisions
    has_many :states, inverse_of: :division

    validates :name, length: {maximum: 30}

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "divisions.csv")
        
        import! do
          load_data_file(location) do |row|
            load_record!(id: row["Division ID"]) do |record|
              record.name = row["Division Name"]
              record.region_id = row["Region ID"]
            end
          end
        end
      end
    end

  end
end
