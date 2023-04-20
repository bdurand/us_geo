# USGeo

[![Build Status](https://travis-ci.com/bdurand/us_geo.svg?branch=master)](https://travis-ci.com/bdurand/us_geo)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

This gem provides a variety of U.S. geographic data ActiveRecord models. It is designed to provide a normalized way to access the data from a relational database. This is by no means a complete set of data. The primary purpose it was built is to provide a way to match most ZIP codes to higher level geographic entities.

## Entities

All of the entities except for DMA are defined by the U.S. Census Bureau. For more details.

https://www2.census.gov/geo/pdfs/reference/geodiagram.pdf
https://www2.census.gov/geo/pdfs/reference/GARM/Ch2GARM.pdf

All entities in the system are keyed using external identifier.

* The various `geoid` columns reference the id used by the U.S. Census Bureau.

* The `gnis_id` columns are the official ID's assigned by the U.S. Board on Geographic Names https://geonames.usgs.gov.


There are no foreign key constraints defined on the tables. This is intentional so that you can only import as much data as you need if you don't need the whole set.

The data set currently contains

* 4 Regions
* 9 Divisions
* 56 States and Territories
* 175 Combined Statistical Areas
* 939 Core Based Statistical Areas
* 31 Metropolitan Divisions
* 3226 Counties or equivalents
* 35,697 County Subdivisions
* 31,847 Places
* 33,792 ZIP Code Tabulation Areas

In addition, there entity to entity mapping tables:

* 46,953 ZCTA to County
* 109549 ZCTA to County Subdivision
* 53,131 ZCTA to Place
* 33,084 Place to County

The land and water area for all entities is given in square miles.

### Region

A grouping of divisions into four regions: Northeast, Midwest, South, West.

### Division

A grouping of states within a region.

### State

Includes both states and territories and the District of Columbia.

### Combined Statistical Areas

Groupings of adjacent CBSA's with regional ties to each other.

### Core Based Statistical Area (CBSA)

A grouping of counties around an urban core defined by commuting patterns. CBSA's are split into metropolitan (population > 50,000) and micropolitan areas. Counties within a CBSA are either identified as being core or outlyer counties. Not all counties belong to a CBSA.

### Metropolitan Division

The largest CBSAs (New York, Chicago, etc.) are further split into metropolitan divisions based around the largest regional cities.

### County (or county equivalent)

Basic organizational unit of states and territories. The actual name of the unit can vary depending on the state (i.e. parishes is Louisiana). This also includes cities that are independent of any county.

### County Subdivision

Subdivision of counties. These could be minor civil divisions like townships or borroughs, but in some states that don't divide counties, they are census designated places. See https://www.census.gov/geo/reference/gtc/gtc_cousub.html.

### Urban Area

Urbanized areas or clusters. Areas with 2,500 to 50,000 inhabitants is considered an urban cluster while more than 50,000 is an urbanized area. Urban areas can span counties, but the one with the majority of the population is identified as the primary county.

Urban area data is only provided for states, the District of Columbia, Puerto Rico. It is not provided for other U.S. territories.

### Place

A place is an organized area within a state usually corresponding to a city, town, village, etc. Places are within a single state, but may span counties. If a place spans multiple counties, the county with the most land area will be identified as the primary county.

### ZIP Code Tabulation Area (ZCTA)

Approximate equivalent to U.S. Postal Service ZIP codes, but designed for geographic and demographic purposes rather than mail routing. Not all postal ZIP codes are mapped to ZCTAs (i.e. ZIP codes mapped to a single building) and the borders of ZCTAs smooth out some of the irregularities of ZIP codes. Otherwise, they are mostly interchangeable.

ZCTAs can span counties, county subdivisions, and places. A primary county, county subdivision, and place are identified for ZCTA's. This will be the one that includes most of the ZCTA's land area.

ZCTA data is only provided for states, the District of Columbia, Puerto Rico. It is not provided for other U.S. territories.

### Entity Relationships

[![](https://mermaid.ink/img/pako:eNqFVEFuwjAQ_IrlM_kAQpVa0iNS1YhLlcvGXqglx0a2U4lS_t7EDlESlpALZmZ2s5qd-MKFlcjXXGjwPldwdFCXhrVPRNgnHpU1pRljufpR_g4tAgRkU2xrGxPOFFY0lSTbfIkAU-RDg8B5D4dv4FF2L1U-KAH61SHMVXWlzBPRDoOzJ6tVAEOwSiyxo1ralL2rqMIIq1-UD6itbnxAd2M6T9gmy14GQyl0YulU0FvYgfHIxr0SnhYdiXzS5fYvUnHJCU_7ng-VzuzBVEkzt5xt_rJsYaexZraIpzW3ccgI9PMtvfARS1hHxYAwZqHfUpCGCKVVpu-DIEY7njHjMUiK2NEkocnsUZYHRR_UOwFf8RpdDUq2d8ulKyh5-MYaS75ujxIP0OhQ8tJcW2lzkm2W3qUK1vH1AbTHFYcm2OJsxAAkVX9HDSjGql1_i3U_13-31qQd?type=png)](https://mermaid.live/edit#pako:eNqFVEFuwjAQ_IrlM_kAQpVa0iNS1YhLlcvGXqglx0a2U4lS_t7EDlESlpALZmZ2s5qd-MKFlcjXXGjwPldwdFCXhrVPRNgnHpU1pRljufpR_g4tAgRkU2xrGxPOFFY0lSTbfIkAU-RDg8B5D4dv4FF2L1U-KAH61SHMVXWlzBPRDoOzJ6tVAEOwSiyxo1ralL2rqMIIq1-UD6itbnxAd2M6T9gmy14GQyl0YulU0FvYgfHIxr0SnhYdiXzS5fYvUnHJCU_7ng-VzuzBVEkzt5xt_rJsYaexZraIpzW3ccgI9PMtvfARS1hHxYAwZqHfUpCGCKVVpu-DIEY7njHjMUiK2NEkocnsUZYHRR_UOwFf8RpdDUq2d8ulKyh5-MYaS75ujxIP0OhQ8tJcW2lzkm2W3qUK1vH1AbTHFYcm2OJsxAAkVX9HDSjGql1_i3U_13-31qQd)
First add to you Gemfile:

`gem us_geo`

Install the migrations.

```bash
rake us_geo_engine:install:migrations
rake db:migrate
```

Import the data.

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
rake us_geo:import:urban_areas
rake us_geo:import:places
rake us_geo:import:zctas
rake us_geo:import:urban_area_counties
rake us_geo:import:urban_area_county_subdivisions
rake us_geo:import:place_counties
rake us_geo:import:zcta_counties
rake us_geo:import:zcta_county_subdivisions
rake us_geo:import:zcta_places
```

By default this will download the data from files hosted with the project on GitHub and insert/update into the database. If any entity records are found that don't exist in the data files, the `removed` flag on the database rows will be set to `TRUE`.

If you want, you can download the file data files and point to them locally by setting `USGeo.base_data_uri` in an initializer.

You can also load the data programatically by simply calling the `load!` method on each class. This will do the same thing the rake tasks do.

All records imported from the data files will have their status set to 1 (imported). Any records that were previously imported, but that are no longer in the data file, will have their status changed to -1 (removed) to indicate that they are no longer in the official data set. Finally, records added to the tables manually will have their status set to 0 (manual). It is perfectly acceptable to augment the data set to, for example, add new Postal Service ZIP codes that did not exist during the last census.

You can cleanup all previously imported records that are no longer in the current data set by running:

```bash
rake us_geo:import:cleanup
```

This gem can be used outside of a Rails application. You'll just need to copy the migrations by hand and install the import rake tasks.
