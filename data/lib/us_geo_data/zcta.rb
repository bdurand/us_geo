# frozen_string_literal: true

module USGeoData
  class Zcta
    include Processor

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["ZCTA5", "Primary County", "Primary Place", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      zcta_data.each_value do |data|
        csv << [
          data[:zcta],
          data[:primary_county],
          data[:primary_place],
          data[:population],
          data[:housing_units],
          data[:land_area]&.round(3),
          data[:water_area]&.round(3),
          data[:lat],
          data[:lng]
        ]
      end
      output
    end

    def dump_counties_csv(output)
      csv = CSV.new(output)
      csv << ["ZCTA5", "County GEOID", "Land Area", "Water Area"]
      zcta_data.each_value do |zcta|
        zcta[:counties].each do |county_geoid, area|
          csv << [
            zcta[:zcta],
            county_geoid,
            area[:land_area],
            area[:water_area]
          ]
        end
      end
      output
    end

    def dump_places_csv(output)
      csv = CSV.new(output)
      csv << ["ZCTA5", "Place GEOID", "Land Area", "Water Area"]
      zcta_data.each_value do |zcta|
        zcta[:places].each do |place_geoid, area|
          csv << [
            zcta[:zcta],
            place_geoid,
            area[:land_area].round(3),
            area[:water_area].round(3)
          ]
        end
      end
      output
    end

    def dump_zcta_mappings_csv(output)
      csv = CSV.new(output)
      csv << ["ZIP Code", "Active ZCTA5"]
      zcta_10_to_20_mappings.each do |old_zcta, new_zcta|
        csv << [old_zcta, new_zcta]
      end
      output
    end

    def zcta_data
      unless defined?(@zcta_data)
        data = {}

        foreach(data_file(USGeoData::ZCTA_GAZETTEER_FILE), col_sep: "\t") do |row|
          zcta5 = row["GEOID"]
          data[zcta5] = empty_zcta(zcta5).merge(
            land_area: row["ALAND_SQMI"]&.to_f,
            water_area: row["AWATER_SQMI"]&.to_f,
            lat: row["INTPTLAT"]&.to_f,
            lng: row["INTPTLONG"]&.to_f
          )
        end

        add_counties(data)
        add_places(data)
        add_demographics(data)

        @zcta_data = data
      end
      @zcta_data
    end

    def zcta_10_to_20_mappings
      mapping = {}
      foreach(data_file(USGeoData::ZCTA_10_ZCTA_20_REL_FILE), col_sep: "|") do |row|
        old_geoid = row["GEOID_ZCTA5_10"]
        new_geoid = row["GEOID_ZCTA5_20"]
        next if old_geoid.nil? || new_geoid.nil? || old_geoid == new_geoid || zcta_data[old_geoid]

        old_area = row["AREALAND_ZCTA5_10"].to_f
        overlap_area = row["AREALAND_PART"].to_f
        next if old_area == 0 || overlap_area == 0

        overlaps = mapping[old_geoid]
        unless overlaps
          overlaps = {}
          mapping[old_geoid] = overlaps
        end
        overlaps[new_geoid] = overlap_area / old_area
      end

      single_mappings = {}
      mapping.each do |old_geoid, overlaps|
        new_geoid = overlaps.max_by { |_, overlap| overlap }.first
        single_mappings[old_geoid] = new_geoid
      end
      single_mappings
    end

    private

    def add_demographics(data)
      demographics(data_file(USGeoData::ZCTA_POPULATION_FILE)).each do |zcta5, population|
        info = data[zcta5]
        info[:population] = population if info
      end

      demographics(data_file(USGeoData::ZCTA_HOUSING_UNITS_FILE)).each do |zcta5, housing_units|
        info = data[zcta5]
        info[:housing_units] = housing_units if info
      end
    end

    def add_counties(data)
      foreach(data_file(USGeoData::ZCTA_COUNTY_REL_FILE), col_sep: "|") do |row|
        zcta5 = row["GEOID_ZCTA5_20"]
        county_geoid = row["GEOID_COUNTY_20"]
        county_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        county_water_area = row["AREAWATER_PART"].to_f * SQUARE_METERS_TO_MILES
        next unless zcta5 && county_geoid && county_land_area > 0

        info = data[zcta5]
        info[:counties][county_geoid] = {land_area: county_land_area, water_area: county_water_area}
      end

      data.each_value do |info|
        info[:primary_county] = info[:counties].max_by { |_, area| area[:land_area] }&.first
      end
    end

    def add_places(data)
      foreach(data_file(USGeoData::ZCTA_PLACE_REL_FILE), col_sep: "|") do |row|
        zcta5 = row["GEOID_ZCTA5_20"]
        place_geoid = row["GEOID_PLACE_20"]
        place_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        place_water_area = row["AREAWATER_PART"].to_f * SQUARE_METERS_TO_MILES
        next unless place_geoid && place_land_area > 0

        info = data[zcta5]
        next unless info

        info[:places][place_geoid] = {land_area: place_land_area, water_area: place_water_area}
      end

      data.each_value do |info|
        info[:primary_place] = info[:places].max_by { |_, area| area[:land_area] }&.first
      end
    end

    def empty_zcta(zcta)
      {
        zcta: zcta,
        population: 0,
        housing_units: 0,
        land_area: 0.0,
        water_area: 0.0,
        counties: {},
        places: {}
      }
    end
  end
end
