# frozen_string_literal: true

# This migration comes from us_geo_engine (originally 20230414000400)
class AddDemographicsToStates < ActiveRecord::Migration[5.0]
  def up
    add_column :us_geo_states, :land_area, :float, null: true
    add_column :us_geo_states, :water_area, :float, null: true
    add_column :us_geo_states, :population, :integer, null: true
    add_column :us_geo_states, :housing_units, :integer, null: true
  end

  def down
    remove_column :us_geo_states, :land_area
    remove_column :us_geo_states, :water_area
    remove_column :us_geo_states, :population
    remove_column :us_geo_states, :housing_units
  end
end
