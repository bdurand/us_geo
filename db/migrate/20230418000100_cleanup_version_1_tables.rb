# frozen_string_literal: true

# WARNING: This migration removes columns and data from version 1 of the gem.
# This will remove the us_geo_designated_market_places table and demographic data from
# relationship tables. Designated market areas are no longer supported in version 2 of the
# gem. If you still want to keep the data and define your own model, then
# you can leave the code in this migration commented out. Otherwise, you can
# uncomment the code below to remove the unused data and columns. If you never
# ran version 1 of the gem, then you can leave the code commented out.
#
# This migration should be run after the gem has been updated to version 2.
class CleanupVersion1Tables < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def up
    # drop_table :us_geo_designated_market_areas if table_exists?(:us_geo_designated_market_areas)

    # remove_column :us_geo_counties, :dma_code if column_exists?(:us_geo_counties, :dma_code)

    # remove_column :us_geo_zcta_counties, :population if column_exists?(:us_geo_zcta_counties, :population)
    # remove_column :us_geo_zcta_counties, :housing_units if column_exists?(:us_geo_zcta_counties, :housing_units)

    # remove_column :us_geo_zcta_places, :population if column_exists?(:us_geo_zcta_places, :population)
    # remove_column :us_geo_zcta_places, :housing_units if column_exists?(:us_geo_zcta_places, :housing_units)

    # remove_column :us_geo_zcta_urban_areas, :population if column_exists?(:us_geo_zcta_urban_areas, :population)
    # remove_column :us_geo_zcta_urban_areas, :housing_units if column_exists?(:us_geo_zcta_urban_areas, :housing_units)

    # remove_column :us_geo_urban_area_counties, :population if column_exists?(:us_geo_urban_area_counties, :population)
    # remove_column :us_geo_urban_area_counties, :housing_units if column_exists?(:us_geo_urban_area_counties, :housing_units)
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end