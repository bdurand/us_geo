class CreateZctas < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_zctas, id: false do |t|
      t.string :zipcode, primary_key: true, null: false, limit: 5
      t.string :primary_county_geoid, null: false, limit: 5, index: true
      t.string :primary_urban_area_geoid, null: true, limit: 5, index: true
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.integer :population, null: false
      t.integer :housing_units, null: false
      t.float :lat, null: false
      t.float :lng, null: false
      t.datetime :updated_at, null: false
      t.boolean :removed, null: false, default: false
    end
  end

  def down
    drop_table :us_geo_zctas
  end

end
