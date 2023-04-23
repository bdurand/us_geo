# frozen_string_literal: true

module USGeo
  # Urban areas are split into either urbanized areas (population > 50,000) or urban cluster (population < 50,000).
  class UrbanArea < BaseRecord
    include Area
    include Population

    self.primary_key = "geoid"
    self.store_full_sti_class = false

    # !@method urban_area_counties
    #   @return [ActiveRecord::Relation<USGeo::UrbanAreaCounty>] County to urban area mapping.
    has_many :urban_area_counties, foreign_key: :urban_area_geoid, inverse_of: :urban_area, dependent: :destroy

    # !@method counties
    #   @return [ActiveRecord::Relation<USGeo::County>] Counties that overlap with the urban area.
    has_many :counties, through: :urban_area_counties

    # !@method primary_county
    #   @return [USGeo::County] Primary county that contains most of the urban area.
    belongs_to :primary_county, foreign_key: :primary_county_geoid, class_name: "USGeo::County"

    # !@method urban_area_county_subdivisions
    #   @return [ActiveRecord::Relation<USGeo::UrbanAreaCountySubdivision>] County subdivision to urban area mapping.
    has_many :urban_area_county_subdivisions, foreign_key: :urban_area_geoid, inverse_of: :urban_area, dependent: :destroy

    # !@method county_subdivisions
    #   @return [ActiveRecord::Relation<USGeo::CountySubdivision>] County subdivisions that overlap with the urban area.
    has_many :county_subdivisions, through: :urban_area_county_subdivisions

    # !@method zcta_urban_areas
    #   @return [ActiveRecord::Relation<USGeo::ZctaUrbanArea>] Zip code to urban area mapping.
    has_many :zcta_urban_areas, foreign_key: :urban_area_geoid, inverse_of: :urban_area, dependent: :destroy

    # !@method zctas
    #   @return [ActiveRecord::Relation<USGeo::Zcta>] Zip codes that overlap with the urban area.
    has_many :zctas, through: :zcta_urban_areas

    # !@method places
    #   @return [ActiveRecord::Relation<USGeo::Place>] Places that overlap with the urban area.
    has_many :places, foreign_key: :urban_area_geoid, inverse_of: :urban_area

    validates :geoid, length: {is: 5}
    validates :primary_county_geoid, length: {is: 5}
    validates :name, length: {maximum: 90}
    validates :short_name, length: {maximum: 60}
    validates :land_area, numericality: true, presence: true
    validates :water_area, numericality: true, presence: true
    validates :population, numericality: {only_integer: true}, presence: true
    validates :housing_units, numericality: {only_integer: true}, presence: true

    # !@method combined_statistical_area
    #   @return [USGeo::CombinedStatisticalArea, nil] Combined statistical area that the urban area is a part of.
    delegate :combined_statistical_area, to: :primary_county, allow_nil: true

    # !@method core_based_statistical_area
    #   @return [USGeo::CoreBasedStatisticalArea, nil] Core-based statistical area that the urban area is a part of.
    delegate :core_based_statistical_area, to: :primary_county, allow_nil: true

    # !@method metropolitan_division
    #   @return [USGeo::MetropolitanDivision, nil] Metropolitan division that the urban area is a part of.
    delegate :metropolitan_division, to: :primary_county, allow_nil: true

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "urban_areas.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(geoid: row["GEOID"]) do |record|
              record.type = ((row["Population"].to_i >= 50_000) ? "UrbanizedArea" : "UrbanCluster")
              record.name = row["Name"]
              record.short_name = row["Short Name"]
              record.primary_county_geoid = row["Primary County GEOID"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
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
