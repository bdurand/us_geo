# frozen_string_literal: true

# This migration comes from us_geo_engine (originally 20220722000200)
class AllowNullZctaPlacesDemographics < ActiveRecord::Migration[5.0]
  def up
    if column_exists?(:us_geo_zcta_places, :population)
      change_column_null :us_geo_zcta_places, :population, true
    end

    if column_exists?(:us_geo_zcta_places, :housing_units)
      change_column_null :us_geo_zcta_places, :housing_units, true
    end
  end

  def down
    if column_exists?(:us_geo_zcta_places, :population)
      change_column_null :us_geo_zcta_places, :population, false
    end

    if column_exists?(:us_geo_zcta_places, :housing_units)
      change_column_null :us_geo_zcta_places, :housing_units, false
    end
  end
end
