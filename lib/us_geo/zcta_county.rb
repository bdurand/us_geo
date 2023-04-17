# frozen_string_literal: true

module USGeo
  # Mapping of ZCTA's to counties they overlap with.
  class ZctaCounty < BaseRecord
    include Area

    self.ignored_columns = %w[population housing_units]

    belongs_to :zcta, foreign_key: :zipcode, inverse_of: :zcta_counties
    belongs_to :county, foreign_key: :county_geoid, inverse_of: :zcta_counties

    validates :zipcode, length: {is: 5}
    validates :county_geoid, length: {is: 5}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "zcta_counties.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZCTA5"], county_geoid: row["County GEOID"]) do |record|
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

    # Percentage of the county land area.
    def percent_county_land_area
      land_area / county.land_area
    end

    # Percentage of the county total area.
    def percent_county_total_area
      total_area / county.total_area
    end
  end
end
