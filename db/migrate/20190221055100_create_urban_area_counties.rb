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
      t.boolean :removed, null: false, default: false
    end

    add_index :us_geo_urban_area_counties, [:urban_area_geoid, :county_geoid], name: :index_us_geo_urban_area_counties_uniq, unique: true
  end

  def down
    drop_table :us_geo_urban_area_counties
  end

end
