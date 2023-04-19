# This migration comes from us_geo_engine (originally 20190221054900)
class CreateZctaCounties < ActiveRecord::Migration[5.0]
  def up
    create_table :us_geo_zcta_counties do |t|
      t.string :zipcode, limit: 5, null: false
      t.string :county_geoid, limit: 5, null: false, index: true
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.integer :population, null: false
      t.integer :housing_units, null: false
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end

    add_index :us_geo_zcta_counties, [:zipcode, :county_geoid], name: :index_us_geo_zcta_counties_uniq, unique: true
  end

  def down
    drop_table :us_geo_zcta_counties
  end
end
