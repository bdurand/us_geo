# frozen_string_literal: true

class AddZctaPrimaryPlace < ActiveRecord::Migration[5.0]
  def up
    return if column_exists?(:us_geo_zctas, :primary_place_geoid)

    add_column :us_geo_zctas, :primary_place_geoid, :string, limit: 7, null: true
  end

  def down
    remove_column :us_geo_zctas, :primary_place_geoid
  end
end
