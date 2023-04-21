# frozen_string_literal: true

module USGeo
  # This module is mixed into all models. Note that the area given for land and water
  # is in square miles.
  module Area
    SQUARE_MILES_TO_KILOMETERS = 2.59
    private_constant :SQUARE_MILES_TO_KILOMETERS

    # @!attribute land_area
    #   @return [Float, nil] Land area in square miles.

    # @!attribute water_area
    #   @return [Integer, nil] Water area in square miles.

    # Total area of both land an water in square miles.
    #
    # @return [Float, nil]
    def total_area
      land_area.to_f + water_area.to_f if land_area
    end

    # The fraction of the area that is composed of land instead of water.
    #
    # @return [Float, nil]
    def percent_land
      land_area / total_area if land_area
    end

    # Land area in square kilometers.
    #
    # @return [Float, nil]
    def land_area_km
      land_area * SQUARE_MILES_TO_KILOMETERS if land_area
    end

    # Water area in square kilometers.
    #
    # @return [Float, nil]
    def water_area_km
      water_area * SQUARE_MILES_TO_KILOMETERS if water_area
    end
  end
end
