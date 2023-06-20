# frozen_string_literal: true

class FixShortNames < ActiveRecord::Migration[5.0]
  def up
    update <<~SQL
      UPDATE us_geo_core_based_statistical_areas
      SET short_name = 'Louisville, KY'
      WHERE short_name = 'Louisville/Jefferson County, KY'
    SQL

    update <<~SQL
      UPDATE us_geo_combined_statistical_areas
      SET short_name = 'Louisville, KY'
      WHERE short_name = 'Louisville/Jefferson County, KY'
    SQL

    update <<~SQL
      UPDATE us_geo_urban_areas
      SET short_name = 'Louisville, KY'
      WHERE short_name = 'Louisville/Jefferson County, KY'
    SQL

    select_all("SELECT geoid, name, short_name FROM us_geo_urban_areas").each do |row|
      name = row["name"].sub(/\s+Urban(?:ized)? (?:Area|Cluster)/, "")
      city, state = name.split(", ", 2)
      short_name = "#{city.split("-").first.split("/").first}, #{state.split("-").first}"
      escaped_short_name = short_name.gsub("'", "''")

      if short_name != row["short_name"]
        update <<~SQL
          UPDATE us_geo_urban_areas
          SET short_name = '#{escaped_short_name}'
          WHERE geoid = '#{row["geoid"]}'
        SQL
      end
    end
  end

  def down
    update <<~SQL
      UPDATE us_geo_core_based_statistical_areas
      SET short_name = 'Louisville/Jefferson County, KY'
      WHERE short_name = 'Louisville, KY'
    SQL

    update <<~SQL
      UPDATE us_geo_combined_statistical_areas
      SET short_name = 'Louisville/Jefferson County, KY'
      WHERE short_name = 'Louisville, KY'
    SQL

    update <<~SQL
      UPDATE us_geo_urban_areas
      SET short_name = 'Louisville/Jefferson County, KY'
      WHERE short_name = 'Louisville, KY'
    SQL
  end
end
