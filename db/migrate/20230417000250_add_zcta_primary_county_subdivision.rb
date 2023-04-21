# frozen_string_literal: true

class AddZctaPrimaryCountySubdivision < ActiveRecord::Migration[5.0]
  def up
    add_column :us_geo_zctas, :primary_county_subdivision_geoid, :string, limit: 10, null: true, index: true
  end

  def down
    add_column :us_geo_zctas, :primary_county_subdivision_geoid, :string, limit: 10, null: true, index: true
  end
end
