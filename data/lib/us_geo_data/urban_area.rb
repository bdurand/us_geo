# frozen_string_literal: true

module USGeoData
  class UrbanArea
    include Processor

    def initialize(counties: nil)
      @counties = nil
    end

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "Name", "Short Name", "Type", "Primary County GEOID", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      urban_area_data.each_value do |data|
        csv << [
          data[:geoid],
          data[:name],
          data[:short_name],
          data[:type],
          data[:primary_county],
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
      csv << ["Urban Area GEOID", "County GEOID", "Land Area", "Water Area"]
      urban_area_data.each_value do |urban_area|
        urban_area[:counties].each do |county_geoid, area|
          csv << [
            urban_area[:geoid],
            county_geoid,
            area[:land_area]&.round(3),
            area[:water_area]&.round(3)
          ]
        end
      end
      output
    end

    def dump_county_subdivisions_csv(output)
      csv = CSV.new(output)
      csv << ["Urban Area GEOID", "County Subdivision GEOID", "Land Area", "Water Area"]
      urban_area_data.each_value do |urban_area|
        urban_area[:county_subdivisions].each do |county_subdivision_geoid, area|
          csv << [
            urban_area[:geoid],
            county_subdivision_geoid,
            area[:land_area]&.round(3),
            area[:water_area]&.round(3)
          ]
        end
      end
      output
    end

    def dump_zctas_csv(output)
      csv = CSV.new(output)
      csv << ["Urban Area GEOID", "ZCTA5", "Land Area", "Water Area"]
      urban_area_data.each_value do |urban_area|
        urban_area[:zctas].each do |zcta5, area|
          csv << [
            urban_area[:geoid],
            zcta5,
            area[:land_area]&.round(3),
            area[:water_area]&.round(3)
          ]
        end
      end
      output
    end

    def urban_area_data
      unless defined?(@urban_area_data)
        urban_areas = {}

        foreach(data_file(USGeoData::URBAN_AREA_GAZETTEER_FILE), col_sep: "\t") do |row|
          urban_area_geoid = row["GEOID"]
          urban_areas[urban_area_geoid] = {
            geoid: urban_area_geoid,
            name: row["NAME"],
            short_name: short_name(row["NAME"]),
            type: ((row["UATYPE"] == "U") ? "UrbanizedArea" : "UrbanCluster"),
            lat: row["INTPTLAT"]&.to_f,
            lng: row["INTPTLONG"]&.to_f,
            land_area: row["ALAND_SQMI"]&.to_f,
            water_area: row["AWATER_SQMI"]&.to_f,
            counties: {},
            county_subdivisions: {},
            zctas: {}
          }
        end

        add_counties(urban_areas)
        add_county_subdivisions(urban_areas)
        add_zctas(urban_areas)
        add_demographics(urban_areas)

        @urban_area_data = urban_areas.reject do |_, info|
          info[:counties].empty? || info[:population].nil? || info[:housing_units].nil?
        end
      end
      @urban_area_data
    end

    private

    def short_name(name)
      name = name.sub(/\s+Urban(?:ized)? (?:Area|Cluster)/, "")
      city, state = name.split(", ", 2)
      "#{city.split("-").first.split("/").first}, #{state.split("-").first}"
    end

    def add_demographics(urban_areas)
      info = JSON.parse(File.read(data_file(USGeoData::URBAN_AREA_DEMOGRAPHICS_FILE)))
      headers = {}
      info.shift.each_with_index { |h, i| headers[h] = i }

      info.each do |row|
        urban_area_geoid = row[headers["urban area"]]
        info = urban_areas[urban_area_geoid]
        if info
          info[:population] = row[headers["B01003_001E"]].to_i
          info[:housing_units] = row[headers["B25001_001E"]].to_i
        end
      end
    end

    def add_counties(urban_areas)
      foreach(data_file(USGeoData::URBAN_AREA_COUNTY_REL_FILE), col_sep: "|") do |row|
        urban_area_geoid = row["GEOID_UA_20"]
        county_geoid = row["GEOID_COUNTY_20"]
        urban_area_land_area = row["AREALAND_UA_20"].to_f * SQUARE_METERS_TO_MILES
        urban_area_water_area = row["AREAWATER_UA_20"].to_f * SQUARE_METERS_TO_MILES
        overlap_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        overlap_water_area = row["AREAWATER_PART"].to_f * SQUARE_METERS_TO_MILES
        next unless urban_area_geoid && county_geoid && overlap_land_area > 0

        info = urban_areas[urban_area_geoid]
        next unless info

        info[:counties][county_geoid] = {land_area: overlap_land_area, water_area: overlap_water_area}
        info[:land_area] = urban_area_land_area
        info[:water_area] = urban_area_water_area
      end

      urban_areas.each_value do |info|
        info[:primary_county] = info[:counties].max_by { |_, area| area[:land_area] }&.first
      end
    end

    def add_county_subdivisions(urban_areas)
      foreach(data_file(USGeoData::URBAN_AREA_COUNTY_SUBDIVISION_REL_FILE), col_sep: "|") do |row|
        urban_area_geoid = row["GEOID_UA_20"]
        county_subdivision_geoid = row["GEOID_COUSUB_20"]
        overlap_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        overlap_water_area = row["AREAWATER_PART"].to_f * SQUARE_METERS_TO_MILES
        next unless urban_area_geoid && county_subdivision_geoid && overlap_land_area > 0

        info = urban_areas[urban_area_geoid]
        next unless info

        info[:county_subdivisions][county_subdivision_geoid] = {land_area: overlap_land_area, water_area: overlap_water_area}
      end
    end

    def add_zctas(urban_areas)
      foreach(data_file(USGeoData::ZCTA_URBAN_AREA_REL_FILE), col_sep: "|") do |row|
        urban_area_geoid = row["GEOID_UA_20"]
        zcta5 = row["GEOID_ZCTA5_20"]
        overlap_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        overlap_water_area = row["AREAWATER_PART"].to_f * SQUARE_METERS_TO_MILES
        next unless urban_area_geoid && zcta5 && overlap_land_area > 0

        info = urban_areas[urban_area_geoid]
        next unless info

        info[:zctas][zcta5] = {land_area: overlap_land_area, water_area: overlap_water_area}
      end
    end

    def county_data
      @counties ||= County.new
      @counties.county_data
    end
  end
end
