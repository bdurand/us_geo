# frozen_string_literal: true

class AddDemographicsToStates < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:us_geo_states, :land_area)
      add_column :us_geo_states, :land_area, :float, null: true
    end

    unless column_exists?(:us_geo_states, :water_area)
      add_column :us_geo_states, :water_area, :float, null: true
    end

    unless column_exists?(:us_geo_states, :population)
      add_column :us_geo_states, :population, :integer, null: true
    end

    unless column_exists?(:us_geo_states, :housing_units)
      add_column :us_geo_states, :housing_units, :integer, null: true
    end
  end

  def down
    remove_column :us_geo_states, :land_area
    remove_column :us_geo_states, :water_area
    remove_column :us_geo_states, :population
    remove_column :us_geo_states, :housing_units
  end
end
