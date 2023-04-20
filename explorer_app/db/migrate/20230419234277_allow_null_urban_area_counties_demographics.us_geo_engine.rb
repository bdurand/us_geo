# frozen_string_literal: true

# This migration comes from us_geo_engine (originally 20230417000400)
class AllowNullUrbanAreaCountiesDemographics < ActiveRecord::Migration[5.0]
  def up
    if column_exists?(:us_geo_urban_area_counties, :population)
      change_column_null :us_geo_urban_area_counties, :population, true
    end

    if column_exists?(:us_geo_urban_area_counties, :housing_units)
      change_column_null :us_geo_urban_area_counties, :housing_units, true
    end
  end

  def down
    if column_exists?(:us_geo_urban_area_counties, :population)
      change_column_null :us_geo_urban_area_counties, :population, false
    end

    if column_exists?(:us_geo_urban_area_counties, :housing_units)
      change_column_null :us_geo_urban_area_counties, :housing_units, false
    end
  end
end
