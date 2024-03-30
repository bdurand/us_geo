# frozen_string_literal: true

require "active_record"

require_relative "us_geo/version"

require_relative "us_geo/engine" if defined?(::Rails::Engine)

module USGeo
  autoload :Area, "us_geo/area"
  autoload :Population, "us_geo/population"
  autoload :BaseRecord, "us_geo/base_record"

  autoload :Region, "us_geo/region"
  autoload :Division, "us_geo/division"
  autoload :State, "us_geo/state"
  autoload :CombinedStatisticalArea, "us_geo/combined_statistical_area"
  autoload :CoreBasedStatisticalArea, "us_geo/core_based_statistical_area"
  autoload :MetropolitanArea, "us_geo/metropolitan_area"
  autoload :MicropolitanArea, "us_geo/micropolitan_area"
  autoload :MetropolitanDivision, "us_geo/metropolitan_division"
  autoload :County, "us_geo/county"
  autoload :CountySubdivision, "us_geo/county_subdivision"
  autoload :Place, "us_geo/place"
  autoload :PlaceCounty, "us_geo/place_county"
  autoload :UrbanArea, "us_geo/urban_area"
  autoload :UrbanAreaCounty, "us_geo/urban_area_county"
  autoload :UrbanAreaCountySubdivision, "us_geo/urban_area_county_subdivision"
  autoload :UrbanCluster, "us_geo/urban_cluster"
  autoload :UrbanizedArea, "us_geo/urbanized_area"
  autoload :Zcta, "us_geo/zcta"
  autoload :ZctaCounty, "us_geo/zcta_county"
  autoload :ZctaCountySubdivision, "us_geo/zcta_county_subdivision"
  autoload :ZctaMapping, "us_geo/zcta_mapping"
  autoload :ZctaPlace, "us_geo/zcta_place"
  autoload :ZctaUrbanArea, "us_geo/zcta_urban_area"

  BASE_DATA_URI = "https://raw.githubusercontent.com/bdurand/us_geo/master/data/2020_dist"

  class << self
    # The root URI as a string of where to find the data files. This can be a URL
    # or a file system path. The default is to load the data from files hosted with
    # the project code on GitHub.
    def base_data_uri
      if defined?(@base_data_uri) && @base_data_uri
        @base_data_uri
      else
        ENV.fetch("US_GEO_BASE_DATA_URI", BASE_DATA_URI)
      end
    end

    def base_data_uri=(value)
      @base_data_uri = value&.to_s
    end
  end
end
