# frozen_string_literal: true

# This migration comes from us_geo_engine (originally 20190221063000)
class CreateCountySubdivisions < ActiveRecord::Migration[5.0]
  def up
    create_table :us_geo_county_subdivisions, id: false do |t|
      t.string :geoid, primary_key: true, limit: 10, null: false
      t.integer :gnis_id, null: false, index: true
      t.string :name, null: false, limit: 60
      t.string :county_geoid, null: false, limit: 5, index: true
      t.string :fips_class_code, null: false, limit: 2
      t.float :land_area, null: true
      t.float :water_area, null: true
      t.integer :population, null: true
      t.integer :housing_units, null: true
      t.float :lat, null: false
      t.float :lng, null: false
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end
  end

  def down
    drop_table :us_geo_county_subdivisions
  end
end
