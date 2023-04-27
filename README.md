# USGeo

[![Build Status](https://travis-ci.com/bdurand/us_geo.svg?branch=master)](https://travis-ci.com/bdurand/us_geo)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

This gem provides a variety of U.S. geographic data ActiveRecord models. It is designed to provide a normalized way to access the data from a relational database. This is by no means a complete set of data.

The primary purpose it was built for is to provide a way to match ZIP codes to higher level geographic entities.

You can use the data from this gem in non-Ruby probjects. The data is provided as [CSV files](./data/2020_dist/) which you can import into any database or spreadsheet. You can see the database structure in the [schema.rb file](./db/schema.rb).

## Entities

All of the entities are defined by the U.S. Census Bureau. For more details.

https://www2.census.gov/geo/pdfs/reference/geodiagram.pdf
https://www2.census.gov/geo/pdfs/reference/GARM/Ch2GARM.pdf

[![](https://mermaid.ink/img/pako:eNqFVEFuwjAQ_IrlM_kAQpVa0iNS1YhLlcvGXqglx0a2U4lS_t7EDlESlpALZmZ2s5qd-MKFlcjXXGjwPldwdFCXhrVPRNgnHpU1pRljufpR_g4tAgRkU2xrGxPOFFY0lSTbfIkAU-RDg8B5D4dv4FF2L1U-KAH61SHMVXWlzBPRDoOzJ6tVAEOwSiyxo1ralL2rqMIIq1-UD6itbnxAd2M6T9gmy14GQyl0YulU0FvYgfHIxr0SnhYdiXzS5fYvUnHJCU_7ng-VzuzBVEkzt5xt_rJsYaexZraIpzW3ccgI9PMtvfARS1hHxYAwZqHfUpCGCKVVpu-DIEY7njHjMUiK2NEkocnsUZYHRR_UOwFf8RpdDUq2d8ulKyh5-MYaS75ujxIP0OhQ8tJcW2lzkm2W3qUK1vH1AbTHFYcm2OJsxAAkVX9HDSjGql1_i3U_13-31qQd?type=png)](https://mermaid.live/edit#pako:eNqFVEFuwjAQ_IrlM_kAQpVa0iNS1YhLlcvGXqglx0a2U4lS_t7EDlESlpALZmZ2s5qd-MKFlcjXXGjwPldwdFCXhrVPRNgnHpU1pRljufpR_g4tAgRkU2xrGxPOFFY0lSTbfIkAU-RDg8B5D4dv4FF2L1U-KAH61SHMVXWlzBPRDoOzJ6tVAEOwSiyxo1ralL2rqMIIq1-UD6itbnxAd2M6T9gmy14GQyl0YulU0FvYgfHIxr0SnhYdiXzS5fYvUnHJCU_7ng-VzuzBVEkzt5xt_rJsYaexZraIpzW3ccgI9PMtvfARS1hHxYAwZqHfUpCGCKVVpu-DIEY7njHjMUiK2NEkocnsUZYHRR_UOwFf8RpdDUq2d8ulKyh5-MYaS75ujxIP0OhQ8tJcW2lzkm2W3qUK1vH1AbTHFYcm2OJsxAAkVX9HDSjGql1_i3U_13-31qQd)

All entities in the system are keyed using external identifiers.

* The various `geoid` columns reference the id used by the [U.S. Census Bureau](https://www.census.gov/programs-surveys/geography/guidance/geo-identifiers.html).

* The `gnis_id` columns are the official ID's assigned by the [U.S. Board on Geographic Names](https://geonames.usgs.gov).


There are no foreign key constraints defined on the tables. This is intentional so that you can only import as much data as you need if you don't need the whole set.

The data set currently contains:

* 4 Regions
* 9 Divisions
* 56 States and Territories
* 175 Combined Statistical Areas
* 939 Core Based Statistical Areas
* 31 Metropolitan Divisions
* 3234 Counties or equivalents
* 35,657 County Subdivisions
* 2,313 Urban Areas
* 31,846 Places
* 33,791 ZIP Code Tabulation Areas

The population, number of housing units, land area, and water area is supplied for all geographic entities.

In addition, there entity to entity mapping tables containing information about how entities overlap with each other:

* 46,953 ZCTA to County
* 109,549 ZCTA to County Subdivision
* 14,455 ZCTA to Urban Area
* 53,131 ZCTA to Place
* 33,276 Place to County
* 33,09 County to Urban Area
* 11,755 County Subdivison to Urban Area

### Region

A grouping of divisions into four regions: Northeast, Midwest, South, West.

### Division

A grouping of states within a region.

### State

Includes both states, territories, and the District of Columbia.

### Core Based Statistical Area (CBSA)

A grouping of counties around an urban core defined by commuting patterns. CBSA's are split into metropolitan (population > 50,000) and micropolitan areas. Counties within a CBSA are either identified as being core or outlyer counties. Not all counties belong to a CBSA.

### Combined Statistical Areas

Groupings of adjacent CBSA's with regional ties to each other.

### Metropolitan Division

The largest CBSAs (New York, Chicago, etc.) are further split into metropolitan divisions based around the largest regional cities.

### County (or county equivalent)

Basic organizational unit of states and territories. The actual name of the unit can vary depending on the state (i.e. parishes is Louisiana). This also includes cities that are independent of any county.

### County Subdivision

Subdivision of counties. These could be minor civil divisions like townships or borroughs, but in some states that don't divide counties, they are census designated places. See https://www.census.gov/geo/reference/gtc/gtc_cousub.html.

### Urban Area

Urbanized areas or clusters. Areas with 2,500 to 50,000 inhabitants is considered an urban cluster while more than 50,000 is an urbanized area. Urban areas can span counties, but the one with the majority of the population is identified as the primary county.

### Place

A place is an organized area within a state usually corresponding to a city, town, village, etc. Places are within a single state, but may span counties. If a place spans multiple counties, the county with the most land area will be identified as the primary county.

### ZIP Code Tabulation Area (ZCTA)

Approximate equivalent to U.S. Postal Service ZIP codes, but designed for geographic and demographic purposes rather than mail routing. Not all postal ZIP codes are mapped to ZCTAs (i.e. ZIP codes mapped to a single building) and the borders of ZCTAs smooth out some of the irregularities of ZIP codes. Otherwise, they are mostly interchangeable.

ZCTAs can span counties, county subdivisions, and places. A primary county, county subdivision, and place are identified for ZCTA's. This will be the one that includes most of the ZCTA's land area.

ZCTA data is only provided for states, the District of Columbia, Puerto Rico. It is not provided for other U.S. territories.

The U.S. Postal Service adds and removes ZIP Codes as necessary for the efficient delivery of mail. The U.S. Census Bureau updates the ZCTA's to reflect these changes during the decenniel census. The list of retired 2010 ZCTA's can still be used via the `USGeo::Zcta.for_zipcode` method. If you search on a retired ZIP code with this method, it will return the ZCTA with the most land overlap with the retired ZIP code.

## Installation

_Note: if you are not using Rails, then replace all the `rails` commands below with `rake`_

First add to you Gemfile:

`gem us_geo`

Install the migrations.

```bash
rails us_geo_engine:install:migrations
rails db:migrate
```

Import the data.

```bash
rails us_geo:import:all
```

Or, if you only want to import some subset of the data, you can run any number of the following.

```bash
rails us_geo:import:regions
rails us_geo:import:divisions
rails us_geo:import:states
rails us_geo:import:combined_statistical_areas
rails us_geo:import:core_based_statistical_areas
rails us_geo:import:metropolitan_divisions
rails us_geo:import:counties
rails us_geo:import:county_subdivisions
rails us_geo:import:urban_areas
rails us_geo:import:places
rails us_geo:import:zctas
rails us_geo:import:urban_area_counties
rails us_geo:import:urban_area_county_subdivisions
rails us_geo:import:place_counties
rails us_geo:import:zcta_counties
rails us_geo:import:zcta_county_subdivisions
rails us_geo:import:zcta_places
```

By default this will download the data from files hosted with the project on GitHub and insert/update into the database. If any entity records are found that don't exist in the data files, the `removed` flag on the database rows will be set to `TRUE`.

If you want, you can download the file data files and point to them locally by setting `USGeo.base_data_uri` in an initializer.

You can also load the data programatically by simply calling the `load!` method on each class. This will do the same thing the rake tasks do.

All records imported from the data files will have their status set to 1 (imported). Any records that were previously imported, but that are no longer in the data file, will have their status changed to -1 (removed) to indicate that they are no longer in the official data set. Finally, records added to the tables manually will have their status set to 0 (manual). It is perfectly acceptable to augment the data set to, for example, add new Postal Service ZIP codes that did not exist during the last census.

You can cleanup all previously imported records that are no longer in the current data set by running:

```bash
rails us_geo:import:cleanup
```

## Contributing

Open a pull request on GitHub.

Please use the [standardrb](https://github.com/testdouble/standard) syntax and lint your code with `standardrb --fix` before submitting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
