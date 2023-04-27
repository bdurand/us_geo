# frozen_string_literal: true

class AddAdditionalTimeZoneNameToCounties < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:us_geo_counties, :time_zone_2_name)
      add_column :us_geo_counties, :time_zone_2_name, :string, null: true, limit: 30
    end
  end

  def down
    remove_column :us_geo_counties, :time_zone_2_name
  end
end
