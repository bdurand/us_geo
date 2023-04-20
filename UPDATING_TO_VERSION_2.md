# Version 2 Update Guide

## Update Data

When updating from version 1.x of the gem, first run the new database migrations.

```bash
rake us_geo_engine:install:migrations
rake db:migrate
```

Then import the new data.

```bash
rake us_geo:import:all
```

Or, if you only want to import some subset of the data, you can run any number of the following.

```bash
rake us_geo:import:regions
rake us_geo:import:divisions
rake us_geo:import:states
rake us_geo:import:combined_statistical_areas
rake us_geo:import:core_based_statistical_areas
rake us_geo:import:metropolitan_divisions
rake us_geo:import:counties
rake us_geo:import:county_subdivisions
rake us_geo:import:places
rake us_geo:import:zctas
rake us_geo:import:place_counties
rake us_geo:import:zcta_counties
rake us_geo:import:zcta_county_subdivisions
rake us_geo:import:zcta_places
```

## Cleanup Migration

```ruby
class CleanupUsGeoVersion1Tables < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def up
    drop_table :us_geo_designated_market_areas

    remove_column :us_geo_counties, :dma_code

    remove_column :us_geo_zcta_counties, :population
    remove_column :us_geo_zcta_counties, :housing_units

    remove_column :us_geo_zcta_places, :population
    remove_column :us_geo_zcta_places, :housing_units

    remove_column :us_geo_zcta_urban_areas, :population
    remove_column :us_geo_zcta_urban_areas, :housing_units

    remove_column :us_geo_urban_area_counties, :population
    remove_column :us_geo_urban_area_counties, :housing_units
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```

## Restoring Designated Market Area

```ruby
module USGeo
  class DesignatedMarketArea < BaseRecord
    include Population
    include Area

    self.primary_key = "code"

    has_many :counties, foreign_key: :dma_code, inverse_of: :designated_market_area
  end
end

USGeo::County.belongs_to :designated_market_area, foreign_key: :dma_code, optional: true, inverse_of: :counties
```
