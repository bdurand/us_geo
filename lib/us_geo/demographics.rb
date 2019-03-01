# frozen_string_literal: true

module USGeo
  
  # This module is mixed into all models. Note that the area given for land and water
  # is in square miles.
  module Demographics

    # Population per square mile.
    def population_density
      population.to_f / land_area
    end

    # Total area of both land an water in square miles
    def total_area
      land_area + water_area
    end

    # The fraction of the area that is composed of land instead of water.
    def percent_land
      land_area / total_area
    end

  end
end
