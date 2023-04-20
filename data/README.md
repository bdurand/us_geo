# Data Files

## Distribution Files

These are the CSV files that can be downloaded from the gem. They are generated from raw data downloaded from various government sources and processed with the data_normalizer.rb script.

The `dist` directory contains data from the 2010 census and is used by the 1.0 version of the gem. These files are locked and no longer being generated.

The `2020_dist` directory contains data from the 2020 census and is used by the 1.1 version of the gem.

## Raw Files

These are the raw files used to construct the data.

### Gazetteer Files

The `data/raw/*_Gaz_*` files are are U.S. Census Gazetteer files update annually with the core data about each entity. The latest copies can be located from the Census geography reference files.

URL: https://www.census.gov/geographies/reference-files.html

Header:
```
USPS	GEOID	ANSICODE	NAME	ALAND	AWATER	ALAND_SQMI	AWATER_SQMI	INTPTLAT	INTPTLONG
```

### Relationship Files

The `data/raw/tab*` files are relationship files from the U.S. Census describing the relationship between entities. They are updated with every census. The latest copies can be located from the Census geography reference files.

URL: https://www.census.gov/geographies/reference-files.html

### Population Files

https://data.census.gov/table?t=Population+Total

Populations are based on the American Community Survey 5 year estimate population totals (B01003).
Housing units are based on the American Community Survey 5 year estimate population totals (B25001).

Urban Area populations are from the Census API:

https://api.census.gov/data/2021/acs/acs5?get=NAME,B01003_001E,B25001_001E&for=urban%20area:*

### Names File

The `data/raw/NationalFedCodes_*` is the USGS GNIS names file with federal codes. It contains the FIPS-55 codes from the U.S. Geological Survey.

URL: https://www.usgs.gov/u.s.-board-on-geographic-names/download-gnis-data

Header: ```
FEATURE_ID|FEATURE_NAME|FEATURE_CLASS|CENSUS_CODE|CENSUS_CLASS_CODE|GSA_CODE|OPM_CODE|STATE_NUMERIC|STATE_ALPHA|COUNTY_SEQUENCE|COUNTY_NUMERIC|COUNTY_NAME|PRIMARY_LATITUDE|PRIMARY_LONGITUDE|DATE_CREATED|DATE_EDITED
```

### Delineation File

The `data/raw/list1_*` file is the CBSA deliniation file from the U.S. Census. It is updated every two years or so.

URL: https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html

This files is exported from Excel and it may have extraneous header and footer information in the file. You should edit the downlownloaded file to remove any header and footer so that the file only includes the field names and data.

Header:
```
CBSA Code,Metropolitan Division Code,CSA Code,CBSA Title,Metropolitan/Micropolitan Statistical Area,Metropolitan Division Title,CSA Title,County/County Equivalent,State Name,FIPS State Code,FIPS County Code,Central/Outlying County
```

### Curated Files

The `data/raw/county_info.csv` file is a hand maintained CSV file. It is the source of county short names, DMA codes, and time zones. If counties are missing the information needs to be looked up and added here manually. Run this rake task to validate the file and show any missing data.

Header:
```
GEOID,Short Name,Full Name,State,DMA Code,Time Zone,FIPS Class
```

The `data/raw/divisions.csv` file is a hand maintained CSV file of the divisions and regions defined for the United States.

Header:
```
Region ID,Region Name,Division ID,Division Name
```

The `data/raw/states.csv` file is a hand maintained CSV file of the states and territories of the United States.

Header:
```
Name,Code,Type,FIPS,Region ID,Division ID
```

The `data/raw/dmas.csv` file is a hand maintained CSV file of the list of Designated Market Areas.

Header:
```
Code,Name
```

### Pre-process the GNIS names file

The GNIS names file needs to be preprocessed and split by geographic entity type. Run this command to update the files in the `data/preprocessed` directory:

```bash
rake data:preprocess_gnis_data
```

### Check the county_info.csv file

Run this command:

```bash
rake data:validate_counties
```

If there are any errors, edit the `data/raw/counties_info.csv` to add any missing data.

### Generate the distribution files
