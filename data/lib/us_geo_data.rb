# frozen_string_literal: true

require "csv"
require "json"
require "net/http"
require "uri"

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
require_relative "us_geo_data/zcta_shape"

module USGeoData
  SQUARE_METERS_TO_MILES = 0.0000003861021585424458

  LATEST_CENSUS_API_YEAR = 2023

  # Information files
  STATES_FILE = File.join("info", "states.csv")
  STATE_DATA_FILE = File.join("info", "state_data.csv")
  COUNTY_TIMEZONE_FILE = File.join("info", "county_timezones.csv")
  EXTRA_COUNTIES_FILE = File.join("info", "extra_counties.csv")
  REGIONS_FILE = File.join("info", "regions.csv")
  DIVISIONS_FILE = File.join("info", "divisions.csv")

  # Gazetteer files
  CBSA_GAZETTEER_FILE = File.join("gazetteer", "2025_Gaz_cbsa_national.txt")
  ZCTA_GAZETTEER_FILE = File.join("gazetteer", "2025_Gaz_zcta_national.txt")
  COUNTY_GAZETTEER_FILE = File.join("gazetteer", "2025_Gaz_counties_national.txt")
  SUBDIVISION_GAZETTEER_FILE = File.join("gazetteer", "2025_Gaz_cousubs_national.txt")
  PLACE_GAZETTEER_FILE = File.join("gazetteer", "2025_Gaz_place_national.txt")
  URBAN_AREA_GAZETTEER_FILE = File.join("gazetteer", "2025_Gaz_ua_national.txt")

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
  COUNTY_DEMOGRAPHICS_FILE = File.join("demographics", "county_2023.json")
  COUNTY_SUBDIVISION_DEMOGRAPHICS_FILE = File.join("demographics", "county_subdivision_2023.json")
  PLACE_DEMOGRAPHICS_FILE = File.join("demographics", "place_2023.json")
  URBAN_AREA_DEMOGRAPHICS_FILE = File.join("demographics", "urban_area_2023.json")
  ZCTA_DEMOGRAPHICS_FILE = File.join("demographics", "zip_code_tabulation_area_2023.json")

  # USGS names file
  GNIS_DATA_FILE = File.join("gnis", "FederalCodes_National_20251121.txt")

  # SQLite database file for ZCTA GIS data.
  ZCTA_GIS_DB_FILE = File.join("tiger", "zcta_gis.db")

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

        open_file("non_census_places.csv") { |file| places.dump_non_census_places_csv(file) }
      end

      if files.empty? || files.include?(:urban_areas)
        urban_areas = UrbanArea.new
        open_file("urban_areas.csv") { |file| urban_areas.dump_csv(file) }
        open_file("urban_area_counties.csv") { |file| urban_areas.dump_counties_csv(file) }
        open_file("urban_area_county_subdivisions.csv") { |file| urban_areas.dump_county_subdivisions_csv(file) }
        open_file("zcta_urban_areas.csv") { |file| urban_areas.dump_zctas_csv(file) }
      end
    end

    def fetch_demographics_files(year = LATEST_CENSUS_API_YEAR)
      base_uri = "https://api.census.gov/data/#{year}/acs/acs5?get=NAME,B01003_001E,B25001_001E"

      ["county", "urban area", "zip code tabulation area", "place"].each do |geo|
        uri = "#{base_uri}&for=#{URI.encode_www_form_component(geo)}:*"
        file_name = File.join(__dir__, "..", "raw", "demographics", "#{geo.gsub(" ", "_")}_#{year}.json")

        puts "Fetching #{geo} demographics data"
        response = fetch_uri(uri)
        File.open(file_name, "w") { |file| file.write(response) }
      end

      cousub_data =[]
      State.new.fips_codes.each do |state_fips, state_name|
        uri = "#{base_uri}&for=county subdivision:*&in=state:#{state_fips}"
        puts "Fetching county subdivision demographics data for #{state_name} (FIPS #{state_fips})"
        response = fetch_uri(uri)
        unless response.empty?
          data = JSON.parse(response)
          header = data.shift
          cousub_data << header if cousub_data.empty?
          cousub_data.concat(data)
        end
      end

      cousub_file_name = File.join(__dir__, "..", "raw", "demographics", "county_subdivision_#{year}.json")
      File.open(cousub_file_name, "w") do |file|
        file.write(JSON.generate(cousub_data, array_nl: "\n", object_nl: ""))
      end
    end

    private

    def open_file(file_name, &block)
      File.open(File.join(__dir__, "..", "2020_dist", file_name), "w", &block)
    end

    def fetch_uri(uri)
      uri = URI(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise "HTTP request failed: #{response.code} #{response.message}"
      end

      response.body.to_s
    end
  end
end
