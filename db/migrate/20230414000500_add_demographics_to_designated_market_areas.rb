# frozen_string_literal: true

class AddDemographicsToDesignatedMarketAreas < ActiveRecord::Migration[5.0]
  def up
    add_column :us_geo_designated_market_areas, :land_area, :float, null: true
    add_column :us_geo_designated_market_areas, :water_area, :float, null: true
    add_column :us_geo_designated_market_areas, :population, :integer, null: true
    add_column :us_geo_designated_market_areas, :housing_units, :integer, null: true
  end

  def down
    remove_column :us_geo_designated_market_areas, :land_area
    remove_column :us_geo_designated_market_areas, :water_area
    remove_column :us_geo_designated_market_areas, :population
    remove_column :us_geo_designated_market_areas, :housing_units
  end
end
