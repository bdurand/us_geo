# USGeo

[![Build Status](https://travis-ci.com/bdurand/us_geo.svg?branch=master)](https://travis-ci.com/bdurand/us_geo)
[![Maintainability](https://api.codeclimate.com/v1/badges/18797b64151284648a05/maintainability)](https://codeclimate.com/github/bdurand/us_geo/maintainability)

This gem provides a variety of U.S. geographic data ActiveRecord models. It is designed to provide a normalized way to access the data from a relational database. This is by no means a complete set of data. The primary purpose it was built is to provide a way to match most ZIP codes to higher level geographic entities.

## Entities

The geographic areas from the lowest level to the highest. All of the entities except for DMA are defined by the U.S. Census Bureau. For more details see https://www.census.gov/content/dam/Census/data/developers/geoareaconcepts.pdf.

All entities in the system are keyed using external identifier. The various `geoid` columns reference the id used by the U.S. Census Bureau.

### ZIP Code Tabulation Area (ZCTA)

Approximate equivalent to U.S. Postal Service ZIP codes, but designed for geographic and demographic purposes rather than mail routing. Not all postal ZIP codes are mapped to ZCTAs (i.e. ZIP codes mapped to a single building) and the borders of ZCTAs smooth out some of the irregularities of ZIP codes. Otherwise, they are mostly interchangeable.

ZCTAs can span counties and urban areas, but have primary county and urban identified where the majority of the population lives.

ZCTA data is only provided for states, the District of Columbia, Puerto Rico. It is not provided for other U.S. territories.

### Urban Area

Urbanized areas or clusters. Areas with 2,500 to 50,000 inhabitants is considered an urban cluster while more than 50,000 is an urbanized area. Urban areas can span counties, but the one with the majority of the population is identified as the primary county.

Urban area data is only provided for states, the District of Columbia, Puerto Rico. It is not provided for other U.S. territories.

### County (or county equivalent)

Basic organizational unit of states and territories. The actual name of the unit can vary depending on the state (i.e. parishes is Louisiana).

County data is only provided for states, the District of Columbia, Puerto Rico. It is not provided for other U.S. territories.

### Core Based Statistical Area (CBSA)

A grouping of counties around an urban core defined by commuting patterns. CBSA's are split into metropolitan (population > 50,000) and micropolitan areas. Counties within a CBSA are either identified as being core or outlyer counties. Not all counties belong to a CBSA.

### Metropolitan Division

The largest CBSAs (New York, Chicago, etc.) are split into metropolitan divisions.

### Combined Statistical Areas

Groupings of adjacent CBSA's with regional ties to each other.

### Designated Market Area (DMA)

Media marketing areas of counties served by the same over the air radio and television signals. DMA's are not official government designations and are defined by the Nielsen Company.

### State

Includes both states and territories and the District of Columbia.

### Division

A grouping of states.

### Region

A grouping of divisions.
