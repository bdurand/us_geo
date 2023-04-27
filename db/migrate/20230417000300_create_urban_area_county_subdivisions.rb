# frozen_string_literal: true

class CreateUrbanAreaCountySubdivisions < ActiveRecord::Migration[5.0]
  def up
    return if table_exists?(:us_geo_urban_area_county_subdivisions)

    create_table :us_geo_urban_area_county_subdivisions do |t|
      t.string :urban_area_geoid, limit: 5, null: false
      t.string :county_subdivision_geoid, limit: 10, null: false
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end

    add_index :us_geo_urban_area_county_subdivisions, [:urban_area_geoid, :county_subdivision_geoid], name: :index_us_geo_urban_area_county_subdivisions_uniq, unique: true
    add_index :us_geo_urban_area_county_subdivisions, [:county_subdivision_geoid], name: :index_us_geo_urban_area_county_subdivisions_geoid
  end

  def down
    drop_table :us_geo_urban_area_county_subdivisions
  end
end
