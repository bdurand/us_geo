# This migration comes from us_geo_engine (originally 20190221054500)
class CreateCombinedStatisticalAreas < ActiveRecord::Migration[5.0]
  def up
    create_table :us_geo_combined_statistical_areas, id: false do |t|
      t.string :geoid, primary_key: true, null: false, limit: 3
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
    drop_table :us_geo_combined_statistical_areas
  end
end
