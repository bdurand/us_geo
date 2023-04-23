# frozen_string_literal: true

module USGeo
  # Mapping of ZCTA's to counties they overlap with.
  class ZctaCountySubdivision < BaseRecord
    include Area

    belongs_to :zcta, foreign_key: :zipcode, inverse_of: :zcta_county_subdivisions
    belongs_to :county_subdivision, foreign_key: :county_subdivision_geoid, inverse_of: :zcta_county_subdivisions

    validates :zipcode, length: {is: 5}
    validates :county_subdivision_geoid, length: {is: 10}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "zcta_county_subdivisions.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZCTA5"], county_subdivision_geoid: row["County Subdivision GEOID"]) do |record|
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
            end
          end
        end
      end
    end

    # Percentage of the ZCTA land area.
    def percent_zcta_land_area
      land_area / zcta.land_area
    end

    # Percentage of the ZCTA total area.
    def percent_zcta_total_area
      total_area / zcta.total_area
    end

    # Percentage of the county subdivision land area.
    def percent_county_subdivision_land_area
      land_area / county_subdivision.land_area
    end

    # Percentage of the county subdivision total area.
    def percent_county_subdivision_total_area
      total_area / county_subdivision.total_area
    end
  end
end
