# frozen_string_literal: true

# This migration comes from us_geo_engine (originally 20190221062000)
class CreateZctaPlaces < ActiveRecord::Migration[5.0]
  def up
    create_table :us_geo_zcta_places do |t|
      t.string :zipcode, limit: 5, null: false
      t.string :place_geoid, limit: 7, null: false, index: true
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end

    add_index :us_geo_zcta_places, [:zipcode, :place_geoid], name: :index_us_geo_us_geo_zcta_places_uniq, unique: true
  end

  def down
    drop_table :us_geo_zcta_places
  end
end
