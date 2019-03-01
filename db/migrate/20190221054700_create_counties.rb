class CreateCounties < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_counties, id: false do |t|
      t.string :geoid, primary_key: true, limit: 5, null: false
      t.string :cbsa_geoid, null: true, limit: 5, index: true
      t.string :metropolitan_division_geoid, limit: 5, null: true, index: true
      t.string :name, null: false, limit: 60
      t.string :short_name, null: false, limit: 30
      t.string :state_code, null: false, limit: 2
      t.boolean :central, default: false
      t.string :fips_class_code, null: false, limit: 2
      t.string :time_zone_name, null: true, limit: 30
      t.string :dma_code, limit: 3, null: true, index: true
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.integer :population, null: false
      t.integer :housing_units, null: false
      t.float :lat, null: false
      t.float :lng, null: false
      t.datetime :updated_at, null: false
      t.boolean :removed, null: false, default: false
    end

    add_index :us_geo_counties, [:name, :state_code], unique: true
  end

  def down
    drop_table :us_geo_counties
  end

end
