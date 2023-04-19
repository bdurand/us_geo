# This migration comes from us_geo_engine (originally 20190221055100)
class CreateUrbanAreaCounties < ActiveRecord::Migration[5.0]
  def up
    create_table :us_geo_urban_area_counties do |t|
      t.string :urban_area_geoid, limit: 5, null: false
      t.string :county_geoid, limit: 5, null: false, index: true
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.integer :population, null: false
      t.integer :housing_units, null: false
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end

    add_index :us_geo_urban_area_counties, [:urban_area_geoid, :county_geoid], name: :index_us_geo_urban_area_counties_uniq, unique: true
  end

  def down
    drop_table :us_geo_urban_area_counties
  end
end
