# frozen_string_literal: true

module USGeo

  # Urban areas are split into either urbanized areas (population > 50,000) or urban cluster (population < 50,000).
  class UrbanArea < BaseRecord

    include Demographics

    self.primary_key = "geoid"
    self.store_full_sti_class = false

    has_many :urban_area_counties, foreign_key: :urban_area_geoid, inverse_of: :urban_area, dependent: :destroy
    has_many :counties, through: :urban_area_counties
    belongs_to :primary_county, foreign_key: :primary_county_geoid, class_name: "USGeo::County"
    
    has_many :zcta_urban_areas, foreign_key: :urban_area_geoid, inverse_of: :urban_area, dependent: :destroy
    has_many :zctas, through: :zcta_urban_areas

    validates :geoid, length: {is: 5}
    validates :primary_county_geoid, length: {is: 5}
    validates :name, length: {maximum: 90}
    validates :short_name, length: {maximum: 60}

    delegate :core_based_statistical_area, :designated_market_area, :state, :state_code, :time_zone, to: :primary_county, allow_nil: true

    before_save do
      self.short_name = name.sub(" Urbanized Area", "").sub(" Urban Cluster", "") if name
    end
    
    class << self
      def load!(location = nil)
        location ||= "#{BaseRecord::BASE_DATA_URI}/urban_areas.csv.gz"
        mark_removed! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.type = (row["Population"].to_i >= 50_000 ? "UrbanizedArea" : "UrbanCluster")
              record.name = row["Name"]
              record.primary_county_geoid = row["Primary County"]
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

    def urbanized?
      raise NotImplementedError
    end
    
    def cluster?
      raise NotImplementedError
    end

  end
end
