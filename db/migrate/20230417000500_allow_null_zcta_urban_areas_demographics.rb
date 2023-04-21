# frozen_string_literal: true

class AllowNullZctaUrbanAreasDemographics < ActiveRecord::Migration[5.0]
  def up
    if column_exists?(:us_geo_zcta_urban_areas, :population)
      change_column_null :us_geo_zcta_urban_areas, :population, true
    end

    if column_exists?(:us_geo_zcta_urban_areas, :housing_units)
      change_column_null :us_geo_zcta_urban_areas, :housing_units, true
    end
  end

  def down
    if column_exists?(:us_geo_zcta_urban_areas, :population)
      change_column_null :us_geo_zcta_urban_areas, :population, false
    end

    if column_exists?(:us_geo_zcta_urban_areas, :housing_units)
      change_column_null :us_geo_zcta_urban_areas, :housing_units, false
    end
  end
end
