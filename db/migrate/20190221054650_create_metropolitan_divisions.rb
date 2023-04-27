# frozen_string_literal: true

class CreateMetropolitanDivisions < ActiveRecord::Migration[5.0]
  def up
    return if table_exists?(:us_geo_metropolitan_divisions)

    create_table :us_geo_metropolitan_divisions, id: false do |t|
      t.string :geoid, primary_key: true, null: false, limit: 5
      t.string :cbsa_geoid, limit: 5, index: true
      t.string :name, null: false, limit: 60, index: {unique: true}
      t.float :land_area, null: false
      t.float :water_area, null: false
      t.integer :population, null: false
      t.integer :housing_units, null: false
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end
  end

  def down
    drop_table :us_geo_metropolitan_divisions
  end
end
