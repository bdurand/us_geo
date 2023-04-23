# frozen_string_literal: true

class CreateZctaCountySubdivisions < ActiveRecord::Migration[5.0]
  def up
    create_table :us_geo_zcta_county_subdivisions do |t|
      t.string :zipcode, limit: 5, null: false
      t.string :county_subdivision_geoid, limit: 10, null: false, index: {name: :index_us_geo_zcta_county_subdivisions_on_geoid}
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end

    add_index :us_geo_zcta_county_subdivisions, [:zipcode, :county_subdivision_geoid], name: :index_us_geo_zcta_county_subdivisions_uniq, unique: true
  end

  def down
    drop_table :us_geo_zcta_county_subdivisions
  end
end
