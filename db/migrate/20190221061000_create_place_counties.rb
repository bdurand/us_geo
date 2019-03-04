class CreatePlaceCounties < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_place_counties do |t|
      t.string :place_geoid, limit: 7, null: false
      t.string :county_geoid, limit: 5, null: false, index: true
      t.datetime :updated_at, null: false
      t.boolean :removed, null: false, default: false
    end

    add_index :us_geo_place_counties, [:place_geoid, :county_geoid], name: :index_us_geo_place_counties_uniq, unique: true
  end

  def down
    drop_table :us_geo_place_counties
  end

end
