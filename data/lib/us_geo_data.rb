# frozen_string_literal: true

require "csv"
require "json"

require_relative "us_geo_data/processor"

require_relative "us_geo_data/combined_statistical_area"
require_relative "us_geo_data/core_based_statistical_area"
require_relative "us_geo_data/county_subdivision"
require_relative "us_geo_data/county"
require_relative "us_geo_data/division"
require_relative "us_geo_data/gnis"
require_relative "us_geo_data/metropolitan_division"
require_relative "us_geo_data/place"
require_relative "us_geo_data/region"
require_relative "us_geo_data/state"
require_relative "us_geo_data/urban_area"
require_relative "us_geo_data/zcta"

module USGeoData
  SQUARE_METERS_TO_MILES = 0.0000003861021585424458

  # Information files
  STATES_FILE = File.join("info", "states.csv")
  STATE_DATA_FILE = File.join("info", "state_data.csv")
  COUNTY_TIMEZONE_FILE = File.join("info", "county_timezones.csv")
  EXTRA_COUNTIES_FILE = File.join("info", "extra_counties.csv")
  REGIONS_FILE = File.join("info", "regions.csv")
  DIVISIONS_FILE = File.join("info", "divisions.csv")

  # Gazetteer files
  CBSA_GAZETTEER_FILE = File.join("gazetteer", "2023_Gaz_cbsa_national.txt")
  ZCTA_GAZETTEER_FILE = File.join("gazetteer", "2023_Gaz_zcta_national.txt")
  COUNTY_GAZETTEER_FILE = File.join("gazetteer", "2023_Gaz_counties_national.txt")
  SUBDIVISION_GAZETTEER_FILE = File.join("gazetteer", "2023_Gaz_cousubs_national.txt")
  PLACE_GAZETTEER_FILE = File.join("gazetteer", "2023_Gaz_place_national.txt")
  URBAN_AREA_GAZETTEER_FILE = File.join("gazetteer", "2023_Gaz_ua_national.txt")

  # Relationship files
  ZCTA_COUNTY_REL_FILE = File.join("relationships", "tab20_zcta520_county20_natl.txt")
  ZCTA_COUNTY_SUBDIVISION_REL_FILE = File.join("relationships", "tab20_zcta520_cousub20_natl.txt")
  ZCTA_PLACE_REL_FILE = File.join("relationships", "tab20_zcta520_place20_natl.txt")
  ZCTA_URBAN_AREA_REL_FILE = File.join("relationships", "tab20_ua20_zcta520_natl.txt")
  ZCTA_10_ZCTA_20_REL_FILE = File.join("relationships", "tab20_zcta510_zcta520_natl.txt")
  PLACE_URBAN_AREA_REL_FILE = File.join("relationships", "tab20_ua20_place20_natl.txt")
  URBAN_AREA_COUNTY_REL_FILE = File.join("relationships", "tab20_ua20_county20_natl.txt")
  URBAN_AREA_COUNTY_SUBDIVISION_REL_FILE = File.join("relationships", "tab20_ua20_cousub20_natl.txt")
  CBSA_DELINEATION_FILE = File.join("relationships", "list1_Jul_2023.csv")

  # Population and housing unit files
  COUNTY_POPULATION_FILE = File.join("demographics", "Counties-ACSDT5Y2022.B01003-Data.csv")
  COUNTY_HOUSING_UNITS_FILE = File.join("demographics", "Counties-ACSDT5Y2022.B25001-Data.csv")
  COUSUB_POPULATION_FILE = File.join("demographics", "CountySubdivisions-ACSDT5Y2022.B01003-Data.csv")
  COUSUB_HOUSING_UNITS_FILE = File.join("demographics", "CountySubdivisions-ACSDT5Y2022.B25001-Data.csv")
  PLACE_POPULATION_FILE = File.join("demographics", "Places-ACSDT5Y2022.B01003-Data.csv")
  PLACE_HOUSING_UNITS_FILE = File.join("demographics", "Places-ACSDT5Y2022.B25001-Data.csv")
  ZCTA_POPULATION_FILE = File.join("demographics", "ZCTA5-ACSDT5Y2022.B01003-Data.csv")
  ZCTA_HOUSING_UNITS_FILE = File.join("demographics", "ZCTA5-ACSDT5Y2022.B25001-Data.csv")
  URBAN_AREA_DEMOGRAPHICS_FILE = File.join("demographics", "urban_areas_2022.json")

  # U.S.G.S names file
  GNIS_DATA_FILE = File.join("gnis", "FederalCodes_National_20240329.txt")

  class << self
    def preprocess
      Gnis.new.preprocess
    end

    def dump_all(files = nil)
      files = Array(files)
      counties = County.new
      states = State.new(counties: counties)

      if files.empty? || files.include?(:counties)
        open_file("counties.csv") { |file| counties.dump_csv(file) }
      end

      if files.empty? || files.include?(:states)
        open_file("states.csv") { |file| states.dump_csv(file) }
      end

      if files.empty? || files.include?(:regions)
        open_file("regions.csv") { |file| Region.new(states: states).dump_csv(file) }
      end

      if files.empty? || files.include?(:divisions)
        open_file("divisions.csv") { |file| Division.new(states: states).dump_csv(file) }
      end

      if files.empty? || files.include?(:metropolitan_divisions)
        open_file("metropolitan_divisions.csv") { |file| MetropolitanDivision.new(counties: counties).dump_csv(file) }
      end

      if files.empty? || files.include?(:cbsa)
        open_file("core_based_statistical_areas.csv") { |file| CoreBasedStatisticalArea.new(counties: counties).dump_csv(file) }
      end

      if files.empty? || files.include?(:csa)
        open_file("combined_statistical_areas.csv") { |file| CombinedStatisticalArea.new(counties: counties).dump_csv(file) }
      end

      if files.empty? || files.include?(:county_subdivisions)
        open_file("county_subdivisions.csv") { |file| CountySubdivision.new.dump_csv(file) }
      end

      if files.empty? || files.include?(:zcta)
        zctas = Zcta.new
        open_file("zctas.csv") { |file| zctas.dump_csv(file) }
        open_file("zcta_counties.csv") { |file| zctas.dump_counties_csv(file) }
        open_file("zcta_county_subdivisions.csv") { |file| zctas.dump_county_subdivisions_csv(file) }
        open_file("zcta_places.csv") { |file| zctas.dump_places_csv(file) }
        open_file("zcta_mappings.csv") { |file| zctas.dump_zcta_mappings_csv(file) }
      end

      if files.empty? || files.include?(:places)
        places = Place.new
        open_file("places.csv") { |file| places.dump_csv(file) }
        open_file("place_counties.csv") { |file| places.dump_counties_csv(file) }
      end

      if files.empty? || files.include?(:urban_areas)
        urban_areas = UrbanArea.new
        open_file("urban_areas.csv") { |file| urban_areas.dump_csv(file) }
        open_file("urban_area_counties.csv") { |file| urban_areas.dump_counties_csv(file) }
        open_file("urban_area_county_subdivisions.csv") { |file| urban_areas.dump_county_subdivisions_csv(file) }
        open_file("zcta_urban_areas.csv") { |file| urban_areas.dump_zctas_csv(file) }
      end
    end

    private

    def open_file(file_name, &block)
      File.open(File.join(__dir__, "..", "2020_dist", file_name), "w", &block)
    end
  end
end
