# frozen_string_literal: true

module USGeo

  # Division of very large metropolitian areas into groups of approximately 2.5 million people.
  class Place < BaseRecord

    include Demographics

    self.primary_key = "geoid"

    has_many :zcta_places, foreign_key: :place_geoid, inverse_of: :place, dependent: :destroy
    has_many :zctas, through: :zcta_places

    has_many :place_counties, foreign_key: :place_geoid, inverse_of: :place, dependent: :destroy
    has_many :counties, through: :place_counties
    
    belongs_to :primary_county, foreign_key: :primary_county_geoid, class_name: "USGeo::County"
    belongs_to :urban_area, foreign_key: :urban_area_geoid, optional: true, class_name: "USGeo::UrbanArea"
    belongs_to :state, foreign_key: :state_code, inverse_of: :places

    validates :geoid, length: {is: 7}
    validates :state_code, length: {is: 2}
    validates :primary_county_geoid, length: {is: 5}
    validates :urban_area_geoid, length: {is: 5}, allow_nil: true
    validates :name, length: {maximum: 60}
    validates :short_name, length: {maximum: 60}
    validates :fips_class_code, length: {is: 2}
    validates :land_area, numericality: true, allow_nil: true
    validates :water_area, numericality: true, allow_nil: true
    validates :population, numericality: {only_integer: true}, allow_nil: true
    validates :housing_units, numericality: {only_integer: true}, allow_nil: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "places.csv.gz")
       
        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.gnis_id = row["GNIS ID"]
              record.name = row["Name"]
              record.short_name = row["Short Name"]
              record.state_code = row["State"]
              record.primary_county_geoid = row["County GEOID"]
              record.urban_area_geoid = row["Urban Area GEOID"]
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
