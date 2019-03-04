class CreatePlaces < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_places, id: false do |t|
      t.string :geoid, primary_key: true, limit: 7, null: false
      t.integer :gnis_id, null: false, index: true
      t.string :name, null: false, limit: 60, index: true
      t.string :short_name, null: false, limit: 30, index: true
      t.string :state_code, null: false, limit: 2, index: true
      t.string :primary_county_geoid, null: false, limit: 5, index: true
      t.string :urban_area_geoid, null: true, limit: 5, index: true
      t.string :fips_class_code, null: false, limit: 2
      t.float :land_area, null: true
      t.float :water_area, null: true
      t.integer :population, null: true
      t.integer :housing_units, null: true
      t.float :lat, null: false
      t.float :lng, null: false
      t.datetime :updated_at, null: false
      t.boolean :removed, null: false, default: false
    end
  end

  def down
    drop_table :us_geo_places
  end

end
