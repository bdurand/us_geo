# Data Files

## Distribution Files

These are the CSV files that can be downloaded from the gem. They are generated from raw data downloaded from various government sources and processed with the data_normalizer.rb script.

The `dist` directory contains data from the 2010 census and is used by the 1.0 version of the gem. These files are locked and no longer being generated.

The `2020_dist` directory contains data from the 2020 census and is used by the 1.1 version of the gem.

## Raw Files

These are the raw files used to construct the data.

### Gazetteer Files

The `data/raw/gazetteer` files are U.S. Census Gazetteer files updated annually with the core data about each entity. The latest copies can be located from the Census geography reference files.

URL: https://www.census.gov/geographies/reference-files.html

### Relationship Files

The `data/raw/relationship/tab*` files are relationship files from the U.S. Census describing the relationship between entities. They are updated with every census. The latest copies can be located from the Census geography reference files.

URL: https://www.census.gov/geographies/reference-files.html

### Demographics Files

Populations are based on the American Community Survey 5 year estimate population totals (B01003).
Housing units are based on the American Community Survey 5 year estimate population totals (B25001).

URLs to get the data from the Census API (replace the year as needed):

https://api.census.gov/data/2023/acs/acs5?get=NAME,B01003_001E,B25001_001E&for=county:*

https://api.census.gov/data/2023/acs/acs5?get=NAME,B01003_001E,B25001_001E&for=urban%20area:*

https://api.census.gov/data/2023/acs/acs5?get=NAME,B01003_001E,B25001_001E&for=zip%20code%20tabulation%20area:*

County subdivisions must be fetched by state:

https://api.census.gov/data/2023/acs/acs5?get=NAME,B01003_001E,B25001_001E&for=county%20subdivision:*&in=state:01

The latest data can be fetched with:

```bash
bundle exec rake data:fetch_demographics
```

### Names File

The `FedCodes_National_*.txt` is the USGS GNIS names file with federal codes. It contains the FIPS-55 codes from the U.S. Geological Survey.

URL: https://www.usgs.gov/u.s.-board-on-geographic-names/download-gnis-data

### Delineation File

The `data/raw/relationships/list1_*` file is the CBSA deliniation file from the U.S. Census. It is updated every two years or so.

URL: https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html

This files is exported from Excel and it may have extraneous header and footer information in the file. You should edit the downlownloaded file to remove any header and footer so that the file only includes the field names and data.

### TIGER/Line Shapefiles

The `data/raw/tiger` directory contains TIGER/Line shapefiles from the U.S. Census Bureau. These files contain the GIS shapes for various geographic entities. The only one needed is the zcta520 shapefile for ZCTA shapes.

URL: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html

### ZIP Code file

The `data/raw/usps` directory contains ZIP code data from the U.S. Postal Service in order to associate the USPS preferred locale name with ZCTAs.

URL: https://postalpro.usps.com/ZIP_Locale_Detail

### Curated Files

The files in the info directory are hand curated files to supply infomation missing in other data sources.

- regions.csv: list of regions
- divisions.csv: list of divisions
- states.csv: list of states and their relationship to divisions
- state_data.csv: areas for all states
- county_timezones.csv: time zones for all counties
- extra_counties.csv: county information for counties not in the gazetteer file

### Pre-process the GNIS names file

The GNIS names file needs to be preprocessed and split by geographic entity type. Run this command to update the files in the `data/preprocessed` directory:

```bash
bundle exec rake data:preprocess_gnis_data
```

If there are any errors, edit the `data/raw/counties_info.csv` to add any missing data.

### Generate the distribution files

Update the files in the 2020_dist directory with this command:

```bash
bundle exec rake data:dump_dist
```