# frozen_string_literal: true

class CreatePlaceCounties < ActiveRecord::Migration[5.0]
  def up
    return if table_exists?(:us_geo_place_counties)

    create_table :us_geo_place_counties do |t|
      t.string :place_geoid, limit: 7, null: false
      t.string :county_geoid, limit: 5, null: false, index: true
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end

    add_index :us_geo_place_counties, [:place_geoid, :county_geoid], name: :index_us_geo_place_counties_uniq, unique: true
  end

  def down
    drop_table :us_geo_place_counties
  end
end
