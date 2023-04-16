# frozen_string_literal: true

module USGeo
  # This module is mixed into all models with a population and land area.
  module Population
    # Population per square mile.
    def population_density
      population.to_f / land_area if population && land_area
    end

    # Population per square kilometer.
    def population_density_km
      population.to_f / land_area_km if population && land_area
    end
  end
end
