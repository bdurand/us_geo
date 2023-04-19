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
