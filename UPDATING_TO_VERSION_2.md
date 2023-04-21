# Version 2 Update Guide

## Update Data

When updating from version 1.x of the gem, first install and run the new database migrations:

```bash
rake us_geo_engine:install:migrations
rake db:migrate
```

Then re-import the data:

```bash
rake us_geo:import:all
```

Or, if you only want to import some subset of the data, you can run any number of the following:

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
rake us_geo:import:urban_areas
rake us_geo:import:place_counties
rake us_geo:import:zcta_counties
rake us_geo:import:zcta_county_subdivisions
rake us_geo:import:zcta_places
rake us_geo:import:zcta_urban_areas
rake us_geo:import:urban_area_counties
rake us_geo:import:urban_area_county_subdivisions
```

## Data Changes

A number of records have been removed in the 2020 data set. These records are marked with a `status` of -1 in the record. Removed records can still be found by queries and will show up in `belongs_to` associations. However, they will not be returned by any `has_many` associations.

For instance, if a County Subdivision was removed in the new data set, you could still find it with `CountySubdivision.find`, but calling `county.subdivisions` would not return it. If you want to keep specific records, you can change the `status` to 0 to indicate it was manually added.

You can see how many removed rows are in each table by running:

```bash
rake us_geo:import:removed_counts
```

You can export data from the removed rows to JSON by running:

```bash
rake us_geo:import:dump_removed
```

You can delete the removed rows by running:

```bash
rake us_geo:import:cleanup
```

## Database Changes

There were a few database changes made in version 2. The tables and columns will not be automatically dropped from the database. If you were making use of those values, you can continue to do so. However, they will not be updated in the imported data and support for them has been removed from the code.

### Option 1: Cleaning up the database

If you wish to remove the tables and colums, you can add this migration to do so:

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

If you are using these tables in a production environment, you should instruct the models to ignore columns before dropping them. You can do that by deploying an initializer with this code *before* running the migration to drop the columns:

```
USGeo::County.ignored_columns = %w[dma_code]
USGeo::ZctaCounty.ignored_columns = %w[population housing_units]
USGeo::ZctaPlace.ignored_columns = %w[population housing_units]
USGeo::ZctaUrbanArea.ignored_columns = %w[population housing_units]
USGeo::UrbanAreaCounty.ignored_columns = %w[population housing_units]
```

### Option 2: Restoring the model

You can restore the previous models and methods if you wish to continue using them with this code.

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

module USGeo
  class ZctaPlace
    include Population

    def percent_zcta_population
      population.to_f / zcta.population.to_f
    end

    def percent_place_population
      population.to_f / place.population.to_f
    end
  end
end

module USGeo
  class ZctaCounty
    include Population

    def percent_zcta_population
      population.to_f / zcta.population.to_f
    end

    def percent_county_population
      population.to_f / county.population.to_f
    end
  end
end

module USGeo
  class ZctaUrbanArea
    include Population

    def percent_zcta_population
      population.to_f / zcta.population.to_f
    end

    def percent_urban_area_population
      population.to_f / urban_area.population.to_f
    end
  end
end
```
