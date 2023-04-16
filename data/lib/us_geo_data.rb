# frozen_string_literal: true

require "csv"

load File.join(__dir__, "us_geo_data", "processor.rb")

load File.join(__dir__, "us_geo_data", "combined_statistical_area.rb")
load File.join(__dir__, "us_geo_data", "core_based_statistical_area.rb")
load File.join(__dir__, "us_geo_data", "county_subdivision.rb")
load File.join(__dir__, "us_geo_data", "county.rb")
load File.join(__dir__, "us_geo_data", "division.rb")
load File.join(__dir__, "us_geo_data", "dma.rb")
load File.join(__dir__, "us_geo_data", "gnis.rb")
load File.join(__dir__, "us_geo_data", "metropolitan_division.rb")
load File.join(__dir__, "us_geo_data", "place.rb")
load File.join(__dir__, "us_geo_data", "region.rb")
load File.join(__dir__, "us_geo_data", "state.rb")
load File.join(__dir__, "us_geo_data", "zcta.rb")

module USGeoData
  SQUARE_METERS_TO_MILES = 0.0000003861021585424458

  # Information files
  STATES_FILE = File.join("info", "states.csv")
  STATE_DATA_FILE = File.join("info", "state_data.csv")
  COUNTY_INFO_FILE = File.join("info", "county_info.csv")
  REGIONS_FILE = File.join("info", "regions.csv")
  DIVISIONS_FILE = File.join("info", "divisions.csv")
  DMAS_FILE = File.join("info", "dmas.csv")

  # Gazetteer files
  CBSA_GAZETTEER_FILE = File.join("gazetteer", "2021_Gaz_cbsa_national.txt")
  ZCTA_GAZETTEER_FILE = File.join("gazetteer", "2022_Gaz_zcta_national.txt")
  COUNTY_GAZETTEER_FILE = File.join("gazetteer",  "2022_Gaz_counties_national.txt")
  OLD_COUNTY_GAZETTEER_FILE = File.join("gazetteer", "2018_Gaz_counties_national.txt")
  SUBDIVISION_GAZETTEER_FILE = File.join("gazetteer", "2022_Gaz_cousubs_national.txt")
  PLACE_GAZETTEER_FILE = File.join("gazetteer", "2022_Gaz_place_national.txt")

  # Relationship files
  ZCTA_COUNTY_REL_FILE = File.join("relationships", "tab20_zcta520_county20_natl.txt")
  ZCTA_PLACE_REL_FILE = File.join("relationships", "tab20_zcta520_place20_natl.txt")
  ZCTA_ZCTA_REL_FILE = File.join("relationships", "tab20_zcta510_zcta520_natl.txt")
  PLACE_COUNTY_REL_FILE = File.join("relationships", "tab20_zcta520_county20_natl.txt")
  CBSA_DELINEATION_FILE = File.join("relationships", "list1_Mar_2020.csv")

  # Population and housing unit files
  COUNTY_POPULATION_FILE = File.join("demographics", "Counties-ACSDT5Y2021.B01003-Data.csv")
  COUNTY_HOUSING_UNITS_FILE = File.join("demographics", "Counties-ACSDT5Y2021.B25001-Data.csv")
  COUSUB_POPULATION_FILE = File.join("demographics", "CountySubdivisions-ACSDT5Y2021.B01003-Data.csv")
  COUSUB_HOUSING_UNITS_FILE = File.join("demographics", "CountySubdivisions-ACSDT5Y2021.B25001-Data.csv")
  PLACE_POPULATION_FILE = File.join("demographics", "Places-ACSDT5Y2021.B01003-Data.csv")
  PLACE_HOUSING_UNITS_FILE = File.join("demographics", "Places-ACSDT5Y2021.B25001-Data.csv")
  ZCTA_POPULATION_FILE = File.join("demographics", "ZCTA5-ACSDT5Y2021.B01003-Data.csv")
  ZCTA_HOUSING_UNITS_FILE = File.join("demographics", "ZCTA5-ACSDT5Y2021.B25001-Data.csv")

  # U.S.G.S names file
  GNIS_DATA_FILE = File.join("gnis", "NationalFedCodes_20210825.txt")

  class << self
    def preprocess
      Gnis.new.preprocess
    end

    def dump_all
      counties = County.new
      states = State.new(counties: counties)

      open_file("counties.csv") { |file| counties.dump_csv(file) }

      open_file("states.csv") { |file| states.dump_csv(file) }

      open_file("regions.csv") { |file| Region.new(states: states).dump_csv(file) }
      open_file("divisions.csv") { |file| Division.new(states: states).dump_csv(file) }
      open_file("dmas.csv") { |file| Dma.new(counties: counties).dump_csv(file) }
      open_file("metropolitan_divisions.csv") { |file| MetropolitanDivision.new(counties: counties).dump_csv(file) }
      open_file("core_based_statistical_areas.csv") { |file| CoreBasedStatisticalArea.new(counties: counties).dump_csv(file) }
      open_file("combined_statistical_areas.csv") { |file| CombinedStatisticalArea.new(counties: counties).dump_csv(file) }

      open_file("county_subdivisions.csv") { |file| CountySubdivision.new.dump_csv(file) }

      zctas = Zcta.new
      open_file("zctas.csv") { |file| zctas.dump_csv(file) }
      open_file("zcta_counties.csv") { |file| zctas.dump_counties_csv(file) }
      open_file("zcta_places.csv") { |file| zctas.dump_places_csv(file) }

      places = Place.new
      open_file("places.csv") { |file| places.dump_csv(file) }
      open_file("place_counties.csv") { |file| places.dump_counties_csv(file) }
    end

    private

    def open_file(file_name, &block)
      File.open(File.join(__dir__, "..", "2020_dist", file_name), "w", &block)
    end
  end
end
