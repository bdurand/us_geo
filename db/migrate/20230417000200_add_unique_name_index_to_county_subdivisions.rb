# frozen_string_literal: true

class AddUniqueNameIndexToCountySubdivisions < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def up
    duplicates_sql = <<~SQL
      SELECT t2.geoid, t2.name
      FROM us_geo_county_subdivisions t1,
           us_geo_county_subdivisions t2
      WHERE t1.geoid < t2.geoid
        AND t1.county_geoid = t2.county_geoid
        AND t1.name = t2.name
    SQL

    select_all(duplicates_sql).each do |row|
      update("UPDATE us_geo_county_subdivisions SET name = ? WHERE geoid = ?", nil, ["#{row["name"]} (duplicate)", row["geoid"]])
    end

    add_index :us_geo_county_subdivisions, [:name, :county_geoid], unique: true, name: "index_us_geo_county_subdivisions_on_unique_name"
  end

  def down
    remove_index :us_geo_county_subdivisions, name: "index_us_geo_county_subdivisions_on_unique_name"
  end
end
