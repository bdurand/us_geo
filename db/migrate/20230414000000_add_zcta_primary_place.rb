# frozen_string_literal: true

class AddZctaPrimaryPlace < ActiveRecord::Migration[5.0]
  def up
    add_column :us_geo_zctas, :primary_place_geoid, :string, limit: 7, null: true, index: true
  end

  def down
    add_column :us_geo_zctas, :primary_place_geoid, :string, limit: 7, null: true, index: true
  end
end