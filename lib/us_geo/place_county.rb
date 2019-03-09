# frozen_string_literal: true

module USGeo

  # Mapping of urban areas to counties they overlap with.
  class PlaceCounty < BaseRecord

    belongs_to :county, foreign_key: :county_geoid, inverse_of: :place_counties
    belongs_to :place, foreign_key: :place_geoid, inverse_of: :place_counties

    validates :county_geoid, length: {is: 5}
    validates :place_geoid, length: {is: 7}

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "place_counties.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(place_geoid: row["Place GEOID"], county_geoid: row["County GEOID"]) do |record|
            end
          end
        end
      end
    end

  end
end
