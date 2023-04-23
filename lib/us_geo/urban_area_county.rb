# frozen_string_literal: true

module USGeo
  # Mapping of urban areas to counties they overlap with.
  class UrbanAreaCounty < BaseRecord
    include Area

    belongs_to :county, foreign_key: :county_geoid, inverse_of: :urban_area_counties
    belongs_to :urban_area, foreign_key: :urban_area_geoid, inverse_of: :urban_area_counties

    validates :county_geoid, length: {is: 5}
    validates :urban_area_geoid, length: {is: 5}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "urban_area_counties.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(urban_area_geoid: row["Urban Area GEOID"], county_geoid: row["County GEOID"]) do |record|
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
            end
          end
        end
      end
    end

    # Percentage of the urban area land area.
    def percent_urban_area_land_area
      land_area / urban_area.land_area
    end

    # Percentage of the urban area total area.
    def percent_urban_area_total_area
      total_area / urban_area.total_area
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
