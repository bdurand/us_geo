# frozen_string_literal: true

module USGeo
  # Mapping of ZCTA's to places they overlap with.
  class ZctaPlace < BaseRecord
    include Area

    belongs_to :zcta, foreign_key: :zipcode, inverse_of: :zcta_places
    belongs_to :place, foreign_key: :place_geoid, inverse_of: :zcta_places

    validates :zipcode, length: {is: 5}
    validates :place_geoid, length: {is: 7}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "zcta_places.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZCTA5"], place_geoid: row["Place GEOID"]) do |record|
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
            end
          end
        end
      end
    end

    # Percentage of the ZCTA land area.
    def percent_zcta_land_area
      land_area / zcta.land_area if zcta.land_area.to_f > 0
    end

    # Percentage of the ZCTA total area.
    def percent_zcta_total_area
      total_area / zcta.total_area if zcta.total_area.to_f > 0
    end

    # Percentage of the place land area. Returns nil if the place does not have
    # a land area (i.e. places not included in the Census gazetteer data).
    def percent_place_land_area
      land_area / place.land_area if place.land_area.to_f > 0
    end

    # Percentage of the place total area. Returns nil if the place does not have
    # a land area (i.e. places not included in the Census gazetteer data).
    def percent_place_total_area
      total_area / place.total_area if place.total_area.to_f > 0
    end
  end
end
