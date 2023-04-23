# frozen_string_literal: true

class AddDemographicsToRegions < ActiveRecord::Migration[5.0]
  def up
    add_column :us_geo_regions, :land_area, :float, null: true
    add_column :us_geo_regions, :water_area, :float, null: true
    add_column :us_geo_regions, :population, :integer, null: true
    add_column :us_geo_regions, :housing_units, :integer, null: true
  end

  def down
    remove_column :us_geo_regions, :land_area
    remove_column :us_geo_regions, :water_area
    remove_column :us_geo_regions, :population
    remove_column :us_geo_regions, :housing_units
  end
end
