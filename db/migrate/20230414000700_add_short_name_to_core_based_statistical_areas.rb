# frozen_string_literal: true

class AddShortNameToCoreBasedStatisticalAreas < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def up
    add_column :us_geo_core_based_statistical_areas, :short_name, :string, null: true

    select_all("SELECT geoid, name FROM us_geo_core_based_statistical_areas").each do |row|
      city, state = row["name"].split(", ", 2)
      short_name = "#{city.split("-").first}, #{state.split("-").first}"
      update("UPDATE us_geo_core_based_statistical_areas SET short_name = ? WHERE geoid = ?", nil, [short_name, row["geoid"]])
    end

    change_column_null :us_geo_core_based_statistical_areas, :short_name, false
    add_index :us_geo_core_based_statistical_areas, :short_name, unique: true
  end

  def down
    remove_column :us_geo_core_based_statistical_areas, :short_name
  end
end
