# frozen_string_literal: true

module USGeoData
  class Zcta
    include Processor

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["ZCTA5", "Primary County", "Primary County Subdivision", "Primary Place", "Primary Urban Area", "USPS Locality", "USPS State Code", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      zcta_data.values.sort_by { |data| data[:zcta] }.each do |data|
        csv << [
          data[:zcta],
          data[:primary_county],
          data[:primary_county_subdivision],
          data[:primary_place],
          data[:primary_urban_area],
          data[:usps_locality],
          data[:usps_state_code],
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
            area[:land_area]&.round(3),
            area[:water_area]&.round(3)
          ]
        end
      end
      output
    end

    def dump_county_subdivisions_csv(output)
      csv = CSV.new(output)
      csv << ["ZCTA5", "County Subdivision GEOID", "Land Area", "Water Area"]
      zcta_data.each_value do |zcta|
        zcta[:county_subdivisions].each do |county_subdivision_geoid, area|
          csv << [
            zcta[:zcta],
            county_subdivision_geoid,
            area[:land_area]&.round(3),
            area[:water_area]&.round(3)
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

        foreach(data_file(USGeoData::ZCTA_GAZETTEER_FILE), col_sep: "|") do |row|
          zcta5 = row["GEOID"]
          data[zcta5] = empty_zcta(zcta5).merge(
            land_area: row["ALAND_SQMI"]&.to_f,
            water_area: row["AWATER_SQMI"]&.to_f,
            lat: row["INTPTLAT"]&.to_f,
            lng: row["INTPTLONG"]&.to_f
          )
        end

        add_counties(data)
        add_county_subdivisions(data)
        add_places(data)
        add_urban_areas(data)
        add_usps_localities(data)
        add_demographics(data, USGeoData::ZCTA_DEMOGRAPHICS_FILE, "zip code tabulation area")

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

    def add_counties(data)
      foreach(data_file(USGeoData::ZCTA_COUNTY_REL_FILE), col_sep: "|") do |row|
        zcta5 = row["GEOID_ZCTA5_20"]
        county_geoid = row["GEOID_COUNTY_20"]
        overlap_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        overlap_water_area = row["AREAWATER_PART"].to_f * SQUARE_METERS_TO_MILES
        next unless zcta5 && county_geoid && overlap_land_area > 0

        info = data[zcta5]
        info[:counties][county_geoid] = {land_area: overlap_land_area, water_area: overlap_water_area}
      end

      data.each_value do |info|
        info[:primary_county] = info[:counties].max_by { |_, area| area[:land_area] }&.first
      end
    end

    def add_county_subdivisions(data)
      foreach(data_file(USGeoData::ZCTA_COUNTY_SUBDIVISION_REL_FILE), col_sep: "|") do |row|
        zcta5 = row["GEOID_ZCTA5_20"]
        county_subdivision_geoid = row["GEOID_COUSUB_20"]
        overlap_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        overlap_water_area = row["AREAWATER_PART"].to_f * SQUARE_METERS_TO_MILES
        next unless zcta5 && county_subdivision_geoid && overlap_land_area > 0

        info = data[zcta5]
        info[:county_subdivisions][county_subdivision_geoid] = {land_area: overlap_land_area, water_area: overlap_water_area}
      end

      data.each_value do |info|
        info[:primary_county_subdivision] = info[:county_subdivisions].max_by { |_, area| area[:land_area] }&.first
      end
    end

    def add_places(data)
      foreach(data_file(USGeoData::ZCTA_PLACE_REL_FILE), col_sep: "|") do |row|
        zcta5 = row["GEOID_ZCTA5_20"]
        place_geoid = row["GEOID_PLACE_20"]
        overlap_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        overlap_water_area = row["AREAWATER_PART"].to_f * SQUARE_METERS_TO_MILES
        next unless place_geoid && overlap_land_area > 0

        info = data[zcta5]
        next unless info

        info[:places][place_geoid] = {land_area: overlap_land_area, water_area: overlap_water_area}
      end

      place_processor.gnis_place_mapping.each_value do |place_data|
        zcta = place_data[:zcta]
        next unless zcta

        info = data[zcta]
        next unless info

        geoid = place_data[:geoid]
        info[:places][geoid] = {land_area: 0, water_area: 0}
      end

      data.each_value do |info|
        ordered_places = info[:places].sort_by { |_, area| -area[:land_area] }
        if ordered_places.size > 1
          ordered_places.delete_if { |_, area| area[:land_area] == 0 }
        end
        info[:primary_place] = ordered_places.first&.first
      end
    end

    def add_urban_areas(zctas)
      overlaps = {}
      foreach(data_file(USGeoData::ZCTA_URBAN_AREA_REL_FILE), col_sep: "|") do |row|
        urban_area_geoid = row["GEOID_UA_20"]
        zcta5 = row["GEOID_ZCTA5_20"]
        overlap_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        zcta_land_area = row["AREALAND_ZCTA5_20"].to_f * SQUARE_METERS_TO_MILES

        next unless urban_area_geoid && zcta5 && overlap_land_area > 0 && zcta_land_area > 0
        next unless zctas.include?(zcta5)

        info = overlaps[zcta5]
        unless info
          info = {}
          overlaps[zcta5] = info
        end
        info[urban_area_geoid] = overlap_land_area / zcta_land_area
      end

      overlaps.each do |zcta5, overlap|
        primary_urban_area = overlap.max_by { |_, percent| percent }.first
        zctas[zcta5][:primary_urban_area] = primary_urban_area
      end
    end

    # The USPS file lists the postal facilities that deliver mail to each ZIP code. The locale
    # name on a row is the name of the facility (i.e. "OAK PARK SOUTH" or "BEVERLY HILLS CARRIER
    # ANNEX") rather than a locality, so the city the facility sits in is used as the locality.
    #
    # A ZIP code can be served by facilities in more than one city. Candidates are narrowed to
    # the facilities in the state the census associates with the ZCTA, then to the facilities
    # named after the city they serve (which identifies a city's main post office), and finally
    # to the facilities in the ZCTA's primary place. Each filter is only applied if it leaves at
    # least one candidate. Any remaining ties are broken by the number of facilities in the city
    # and then alphabetically so the generated data is stable between runs.
    def add_usps_localities(data)
      usps_facilities.each do |zcta5, facilities|
        info = data[zcta5]
        next unless info

        state_code = state_code_for_county(info[:primary_county])
        place_name = place_name_for(info[:primary_place])

        facilities = narrow_facilities(facilities) { |facility| facility[:state] == state_code }
        facilities = narrow_facilities(facilities) { |facility| facility[:locale] == facility[:city] }
        facilities = narrow_facilities(facilities) { |facility| facility[:city].casecmp?(place_name.to_s) }

        counts = Hash.new(0)
        facilities.each { |facility| counts[[facility[:city], facility[:state]]] += 1 }
        locality, locality_state_code = counts.min_by { |(city, state), count| [-count, city, state] }.first

        info[:usps_locality] = locality
        info[:usps_state_code] = locality_state_code
      end
    end

    # Return only the facilities matching the block, or all of them if the block matches none.
    def narrow_facilities(facilities)
      matches = facilities.select { |facility| yield(facility) }
      matches.empty? ? facilities : matches
    end

    # Map of ZIP code to the postal facilities that deliver mail to it.
    def usps_facilities
      unless defined?(@usps_facilities)
        facilities = Hash.new { |hash, zipcode| hash[zipcode] = [] }

        foreach(data_file(USGeoData::USPS_ZIP_LOCALE_FILE)) do |row|
          zipcode = row["DELIVERY ZIPCODE"]&.strip
          city = row["PHYSICAL CITY"]&.strip
          state_code = row["PHYSICAL STATE"]&.strip
          next if zipcode.nil? || city.nil? || state_code.nil? || city.empty? || state_code.empty?

          facilities[zipcode] << {locale: row["LOCALE NAME"]&.strip, city: city, state: state_code}
        end

        @usps_facilities = facilities
      end
      @usps_facilities
    end

    def state_code_for_county(county_geoid)
      state_codes_by_fips[county_geoid[0, 2]] if county_geoid
    end

    def state_codes_by_fips
      unless defined?(@state_codes_by_fips)
        codes = {}
        foreach(data_file(USGeoData::STATES_FILE)) { |row| codes[row["FIPS"]] = row["Code"] }
        @state_codes_by_fips = codes
      end
      @state_codes_by_fips
    end

    def place_name_for(place_geoid)
      return nil unless place_geoid

      place = place_processor.place_data[place_geoid]
      place_processor.short_name(place[:name]) if place
    end

    def place_processor
      @place_processor ||= Place.new
    end

    def empty_zcta(zcta)
      {
        zcta: zcta,
        population: 0,
        housing_units: 0,
        land_area: 0.0,
        water_area: 0.0,
        counties: {},
        county_subdivisions: {},
        places: {}
      }
    end
  end
end
