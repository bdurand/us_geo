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
      population.to_f / land_area if population && land_area
    end

    # Population per square kilometer.
    #
    # @return [Float, nil]
    def population_density_km
      population.to_f / land_area_km if population && land_area
    end
  end
end
