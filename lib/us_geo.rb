# frozen_string_literal: true

require "active_record"

require_relative 'us_geo/version'
require_relative 'us_geo/demographics'
require_relative 'us_geo/base_record'
require_relative 'us_geo/region'
require_relative 'us_geo/division'
require_relative 'us_geo/state'
require_relative 'us_geo/designated_market_area'
require_relative 'us_geo/combined_statistical_area'
require_relative 'us_geo/core_based_statistical_area'
require_relative 'us_geo/metropolitan_area'
require_relative 'us_geo/micropolitan_area'
require_relative 'us_geo/metropolitan_division'
require_relative 'us_geo/county'
require_relative 'us_geo/county_subdivision'
require_relative 'us_geo/urban_area'
require_relative 'us_geo/urbanized_area'
require_relative 'us_geo/urban_cluster'
require_relative 'us_geo/urban_area_county'
require_relative 'us_geo/place'
require_relative 'us_geo/place_county'
require_relative 'us_geo/zcta'
require_relative 'us_geo/zcta_urban_area'
require_relative 'us_geo/zcta_county'
require_relative 'us_geo/zcta_place'

require_relative 'us_geo/engine' if defined?(::Rails::Engine)

module USGeo

  BASE_DATA_URI = "https://raw.githubusercontent.com/bdurand/us_geo/master/data/dist"

  class << self
    # The root URI as a string of where to find the data files. This can be a URL
    # or a file system path. The default is to load the data from files hosted with
    # the project code on GitHub.
    def base_data_uri
      if defined?(@base_data_uri) && @base_data_uri
        @base_data_uri
      else
        BASE_DATA_URI
      end
    end

    def base_data_uri=(value)
      @base_data_uri = (value.nil? ? nil : value.to_s)
    end
  end

end
