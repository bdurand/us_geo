# frozen_string_literal: true

class AddDemographicsToDivisions < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:us_geo_divisions, :land_area)
      add_column :us_geo_divisions, :land_area, :float, null: true
    end

    unless column_exists?(:us_geo_divisions, :water_area)
      add_column :us_geo_divisions, :water_area, :float, null: true
    end

    unless column_exists?(:us_geo_divisions, :population)
      add_column :us_geo_divisions, :population, :integer, null: true
    end

    unless column_exists?(:us_geo_divisions, :housing_units)
      add_column :us_geo_divisions, :housing_units, :integer, null: true
    end
  end

  def down
    remove_column :us_geo_divisions, :land_area
    remove_column :us_geo_divisions, :water_area
    remove_column :us_geo_divisions, :population
    remove_column :us_geo_divisions, :housing_units
  end
end
