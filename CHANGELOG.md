# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- Data is now based on the 2020 U.S. Census.
  * ZCTAs have been both added and removed
  * Places have been both added and removed
  * Some counties and subdivisions have been renamed
  * Former U.S. territories (Micronesia, Palau, and Marshall Islands) have been removed.
  * Counties are no longer available for the territories of Guam, U.S. Virgin Islands, and Northern Mariana Islands.

- Population and housing unit numbers are now based on the 2021 American Community Survey Five Year Estimates.

- Entities that are legally independent of other county subdivisions are included as both county subdivisions and places.

- Areas in the CSV data files are now in square miles instead of square meters to match the data that is imported.

### Added

- ZCTA's are now associated with a primary place defined as the place with the most overlapping land area with the ZCTA.

- ZCTAS's are now associated with county subdivisions and have a primary county subdivision which is the one with the moste land area overlapping the ZCTA.

- 2010 ZCTAs can still be used to lookup the active ZCTA through the ZCTAMapping model.

- Core Based Statistical Areas and Combined Statistical Areas now have a short name which is the name of just the largest city in the area. This makes them a little easier to refer to by name.

- All Geographic entity models now have land area, water area, population, and housing units columns.

- More military bases have been added as places.

### Removed

- Designated market area model has been removed. This data was a crude mapping from counties to DMA's and was not accurate since it didn't respect the actual borders. The table and foreign keys to it will not be removed. See the [updating guide](UPDATING_TO_VERSION_2.md) form more details.

- Urbanized area models have been removed. This data is still not available in the 2020 U.S. Census data sets. It was also mostly duplicative with metropolitan areas and created a bit of confusion in the data model. The table and foreign keys to it will not be removed. See the [updating guide](UPDATING_TO_VERSION_2.md) form more details.


- Population and housing unit data has been removed from the overlap models used to join entities (i.e. ZctaCounty, ZctaPlace, PlaceCounty). This information is no longer available directly from the Census relationship files. Only the overlapping land and water area is now available.

- The USGeo::Demographics module has been removed. The functionality is split into USGeo::Area and USGeo::Population.

- Dropped support for ActiveRecord 5.0 and 5.1

- Dropped support for Ruby 2.5.

### Fixed

- Fixed arithmetic for converting area from square miles to kilometers.

## 1.0.3

### Added

- Make dependencies compatible with Rails 6

## 1.0.2

### Added

- Add missing metropolitan division codes to counties

### Changed

- Fix short name logic to be more conservative in how it shortens names

## 1.0.1

### Changed

- Fix logic to enforce place short name limit on databases that don't have character limits.

## 1.0.0

### Added

- Initial release
