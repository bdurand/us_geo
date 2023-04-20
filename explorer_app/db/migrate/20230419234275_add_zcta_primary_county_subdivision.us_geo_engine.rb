# frozen_string_literal: true

# This migration comes from us_geo_engine (originally 20230417000200)
class AddZctaPrimaryCountySubdivision < ActiveRecord::Migration[5.0]
  def up
    add_column :us_geo_zctas, :primary_county_subdivision_geoid, :string, limit: 10, null: true, index: true
  end

  def down
    add_column :us_geo_zctas, :primary_county_subdivision_geoid, :string, limit: 10, null: true, index: true
  end
end
