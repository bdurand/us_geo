# frozen_string_literal: true

module USGeo

  # County subdivision.
  class CountySubdivision < BaseRecord

    include Demographics

    self.primary_key = "geoid"

    belongs_to :county, foreign_key: :county_geoid, inverse_of: :subdivisions

    validates :geoid, length: {is: 10}
    validates :name, length: {maximum: 60}
    validates :fips_class_code, length: {is: 2}
    validates :land_area, numericality: true, allow_nil: true
    validates :water_area, numericality: true, allow_nil: true
    validates :population, numericality: {only_integer: true}, allow_nil: true
    validates :housing_units, numericality: {only_integer: true}, allow_nil: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "county_subdivisions.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.gnis_id = row["GNIS ID"]
              record.county_geoid = row["County GEOID"]
              record.name = row["Name"]
              record.fips_class_code = row["FIPS Class"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = area_meters_to_miles(row["Land Area"])
              record.water_area = area_meters_to_miles(row["Water Area"])
              record.lat = row["Latitude"]
              record.lng = row["Longitude"]
            end
          end
        end
      end
    end

  end
end
