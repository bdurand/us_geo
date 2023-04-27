# frozen_string_literal: true

class AddZctaPrimaryCountySubdivision < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:us_geo_zctas, :primary_county_subdivision_geoid)
      add_column :us_geo_zctas, :primary_county_subdivision_geoid, :string, limit: 10, null: true, index: true
    end
  end

  def down
    add_column :us_geo_zctas, :primary_county_subdivision_geoid, :string, limit: 10, null: true, index: true
  end
end
