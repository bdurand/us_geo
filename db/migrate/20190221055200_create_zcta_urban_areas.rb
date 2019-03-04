class CreateZctaUrbanAreas < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_zcta_urban_areas do |t|
      t.string :zipcode, limit: 5, null: false, index: true
      t.string :urban_area_geoid, limit: 5, null: false
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.integer :population, null: false
      t.integer :housing_units, null: false
      t.datetime :updated_at, null: false
      t.boolean :removed, null: false, default: false
    end

    add_index :us_geo_zcta_urban_areas, [:urban_area_geoid, :zipcode], name: :index_us_geo_urban_area_zctas_uniq, unique: true
  end

  def down
    drop_table :us_geo_zcta_urban_areas
  end

end
