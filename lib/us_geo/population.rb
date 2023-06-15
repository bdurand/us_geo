# frozen_string_literal: true

module USGeo
  # This module is mixed into all models with a population and land area.
  module Population
    # @!attribute population
    #   @return [Integer, nil] Total population of the area.

    # @!attribute housing_units
    #   @return [Integer, nil] Total housing units in the area.

    # Population per square mile.
    #
    # @return [Float, nil]
    def population_density
      population.to_f / land_area if population && land_area.to_f > 0
    end

    # Population per square kilometer.
    #
    # @return [Float, nil]
    def population_density_km
      population.to_f / land_area_km if population && land_area.to_f > 0
    end

    # Housing units per square mile.
    #
    # @return [Float, nil]
    def housing_density
      housing_units.to_f / land_area if housing_units && land_area.to_f > 0
    end

    # Housing units per square kilometer.
    #
    # @return [Float, nil]
    def housing_density_km
      housing_units.to_f / land_area_km if housing_units && land_area.to_f > 0
    end
  end
end
