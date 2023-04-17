# frozen_string_literal: true

class CreateZctaMappings < ActiveRecord::Migration[5.0]
  def up
    create_table :us_geo_zcta_mappings, id: false do |t|
      t.string :zipcode, primary_key: true, null: false, limit: 5
      t.string :zcta_zipcode, null: false, limit: 5, index: true
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end
  end

  def down
    drop_table :us_geo_zcta_mappings
  end
end
