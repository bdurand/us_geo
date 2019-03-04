# frozen_string_literal: true

module USGeo

  # U.S. region.
  class Region < BaseRecord

    has_many :divisions, inverse_of: :region
    has_many :states, inverse_of: :region

    validates :name, length: {maximum: 30}

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "divisions.csv.gz")

        mark_removed! do
          load_data_file(location) do |row|
            load_record!(id: row["Region ID"]) do |record|
              record.name = row["Region Name"]
            end
          end
        end
      end
    end

  end
end
