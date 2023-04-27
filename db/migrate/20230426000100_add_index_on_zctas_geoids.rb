# frozen_string_literal: true

class AddIndexOnZctasGeoids < ActiveRecord::Migration[5.0]
  def up
    unless index_exists?(:us_geo_zctas, :primary_place_geoid)
      add_index :us_geo_zctas, :primary_place_geoid
    end

    unless index_exists?(:us_geo_zctas, :primary_county_subdivision_geoid)
      add_index :us_geo_zctas, :primary_county_subdivision_geoid
    end
  end

  def down
    remove_index :us_geo_zctas, :primary_place_geoid
    remove_index :us_geo_zctas, :primary_county_subdivision_geoid
  end
end
