# frozen_string_literal: true

class CreateRegions < ActiveRecord::Migration[5.0]
  def up
    return if table_exists?(:us_geo_regions)

    create_table :us_geo_regions, id: false do |t|
      t.integer :id, primary_key: true, null: false, limit: 1
      t.string :name, null: false, limit: 30, index: {unique: true}
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end
  end

  def down
    drop_table :us_geo_regions
  end
end
