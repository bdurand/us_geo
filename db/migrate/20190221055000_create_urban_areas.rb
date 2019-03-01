class CreateUrbanAreas < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_urban_areas, id: false do |t|
      t.string :geoid, primary_key: true, null: false, limit: 5
      t.string :name, null: false, limit: 90, index: {unique: true}
      t.string :short_name, null: false, limit: 60, index: {unique: true}
      t.string :primary_county_geoid, null: false, limit: 5, index: true
      t.string :type, null: false, limit: 30
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
    drop_table :us_geo_urban_areas
  end

end
