# This migration comes from us_geo_engine (originally 20190221054300)
class CreateDivisions < ActiveRecord::Migration[5.0]
  def up
    create_table :us_geo_divisions, id: false do |t|
      t.integer :id, primary_key: true, null: false, limit: 1
      t.integer :region_id, null: false, limit: 1, index: true
      t.string :name, null: false, limit: 30, index: {unique: true}
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end
  end

  def down
    drop_table :us_geo_divisions
  end
end
