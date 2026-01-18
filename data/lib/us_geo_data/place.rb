# frozen_string_literal: true

module USGeoData
  class Place
    include Processor

    STATE_ABBREVIATIONS = {
      "Alabama" => "Ala.",
      "Arizona" => "Ariz.",
      "Arkansas" => "Ark.",
      "California" => "Calif.",
      "Colorado" => "Colo.",
      "Connecticut" => "Conn.",
      "Delaware" => "Del.",
      "Florida" => "Fla.",
      "Georgia" => "Ga.",
      "Illinois" => "Ill.",
      "Indiana" => "Ind.",
      "Kansas" => "Kan.",
      "Kentucky" => "Ky.",
      "Louisiana" => "La.",
      "Maryland" => "Md.",
      "Massachusetts" => "Mass.",
      "Michigan" => "Mich.",
      "Minnesota" => "Minn.",
      "Mississippi" => "Miss.",
      "Missouri" => "Mo.",
      "Montana" => "Mont.",
      "Nebraska" => "Neb.",
      "Nevada" => "Nev.",
      "New Hampshire" => "N.H.",
      "New Jersey" => "N.J.",
      "New Mexico" => "N.M.",
      "New York" => "N.Y.",
      "North Carolina" => "N.C.",
      "North Dakota" => "N.D.",
      "Oklahoma" => "Okla.",
      "Oregon" => "Ore.",
      "Pennsylvania" => "Pa.",
      "Rhode Island" => "R.I.",
      "South Carolina" => "S.C.",
      "South Dakota" => "S.D.",
      "Tennessee" => "Tenn.",
      "Vermont" => "Vt.",
      "Virginia" => "Va.",
      "Washington" => "Wash.",
      "West Virginia" => "W.Va.",
      "Wisconsin" => "Wis.",
      "Wyoming" => "Wyo."
    }.freeze

    STRIP_FROM_SHORT_NAME = [
      /\A(The )?City and Borough of /i,
      /\A(The )?Unified Government of /i,
      / unified government\b/i,
      /\A(The )?Consolidated Government of /i,
      /\A(The )?City and County of /i,
      /\A(The )?Metropolitan Government of /i,
      /\A(The )?City of /i,
      /\A(The )?Town of /i,
      /\A(The )?Township of /i,
      /\A(The )?Municipality of /i,
      /\A(The )?Village of /i,
      /\A(The )?Borough of /i,
      /\A(The )?County of /i,
      /\A(The )?Corporation of /i,
      /( Census)? Designated(.*) Place/i,
      / CDP/i,
      / \(historical\)/i,
      / \(balance\)/i,
      / Township/i,
      / Consolidated Government/i,
      / Metro Government/i,
      / Comunidad\z/i,
      / Zona Urbana\z/i
    ].freeze

    ABBREVIATIONS = {
      /\bCensus Designated Place\b/i => "CDP",
      /\b(?:The )?University\b/i => "Univ.",
      /\bInstitute\b/i => "Inst.",
      /\bCollege\b/i => "Coll.",
      /\bMount\b/i => "Mt.",
      /\bMountain\b/i => "Mtn.",
      /\bFort\b/i => "Ft.",
      /\bSaint\b/i => "St.",
      /\bNumber\b/i => "No.",
      /\bEstate(?:s)?\b/i => "Est.",
      /\bPeak\b/i => "Pk.",
      /\bHeights\b/i => "Hts.",
      /\bVillage\b/i => "Vlg.",
      /\bHarbor\b/i => "Hbr.",
      /\bSpring(?:s)?\b/i => "Spg.",
      /\bCountry Club\b/i => "CC",
      /\bSubdivision\b/i => "Subd.",
      /\bProvidencia\b/i => "Prov."
    }.freeze

    INACTIVE_FUNCSTAT_CODES = ["I", "L", "F", "N"].freeze

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "GNIS ID", "Name", "Short Name", "State", "County GEOID", "Urban Area GEOID", "FIPS Class", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]

      place_data.values.sort_by { |data| data[:geoid] }.each do |data|
        unless data[:gnis_id] && data[:fips_class]
          puts "Missing data for place #{data[:geoid]} #{data[:name]}, #{data[:state]}: #{data.inspect}"
          next
        end
        csv << [
          data[:geoid],
          data[:gnis_id],
          abbr_name(data[:name], 60),
          short_name(data[:name]),
          data[:state],
          data[:county_geoid],
          data[:urban_area_geoid],
          data[:fips_class],
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

    def dump_non_census_places_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "GNIS ID", "Name", "Short Name", "State", "County GEOID", "Urban Area GEOID", "FIPS Class", "Latitude", "Longitude"]

      gnis_place_mapping.each_value do |data|
        next unless data[:fips_class] == "U6"

        csv << [
          data[:geoid],
          data[:gnis_id],
          abbr_name(data[:name], 60),
          short_name(data[:name]),
          data[:state],
          data[:county_geoid],
          data[:urban_area_geoid],
          data[:fips_class],
          data[:lat],
          data[:lng]
        ]
      end

      output
    end

    def dump_counties_csv(output)
      csv = CSV.new(output)
      csv << ["Place GEOID", "County GEOID"]
      place_data.each_value do |place|
        place[:counties].each do |county_geoid|
          csv << [
            place[:geoid],
            county_geoid
          ]
        end
      end
      output
    end

    def place_data
      unless defined?(@place_data)
        places = {}

        gnis_places = gnis_place_mapping
        foreach(data_file(USGeoData::PLACE_GAZETTEER_FILE), col_sep: "|") do |row|
          next if INACTIVE_FUNCSTAT_CODES.include?(row["FUNCSTAT"])

          geoid = row["GEOID"]
          gnis_id ||= row["ANSICODE"].gsub(/\A0+/, "").to_i
          data = gnis_places[gnis_id]&.dup
          next unless data

          data[:geoid] = geoid
          data[:land_area] = row["ALAND_SQMI"]&.to_f
          data[:water_area] = row["AWATER_SQMI"]&.to_f
          data[:lat] ||= row["INTPTLAT"]&.to_f
          data[:lng] ||= row["INTPTLONG"]&.to_f
          data[:counties] = [data[:county_geoid]].compact
          places[geoid] = data
        end

        add_demographics(places, USGeoData::PLACE_DEMOGRAPHICS_FILE, ["state", "place"])
        add_counties(places)
        add_urban_areas(places)

        @place_data ||= places
      end
      @place_data
    end

    def short_name(name)
      short_name = name
      STRIP_FROM_SHORT_NAME.each do |pattern|
        short_name = short_name.sub(pattern, "")
      end

      short_name = abbr_name(short_name, 30)
      short_name = abbr_state(short_name) if short_name.size > 30
      short_name = short_name.split("-", 2).first if short_name.size > 30

      if short_name.size > 30
        raise "Short name for #{name} greater than 30 characters: #{short_name.inspect} (#{short_name.size} characters)"
      end

      short_name
    end

    def gnis_place_mapping
      gnis_places = {}

      foreach(processed_file(Gnis::PLACES_FILE), col_sep: ",") do |row|
        gnis_id = row["GNIS ID"].to_i
        gnis_places[gnis_id] = {
          gnis_id: gnis_id,
          geoid: row["GEOID"],
          fips_class: row["FIPS Class"],
          name: row["Name"],
          state: row["State"],
          county_geoid: row["County GEOID"],
          lat: row["Latitude"].to_f,
          lng: row["Longitude"].to_f
        }
      end

      foreach(processed_file(Gnis::NON_CENSUS_PLACES_FILE), col_sep: ",") do |row|
        gnis_id = row["GNIS ID"].to_i
        gnis_places[gnis_id] = {
          gnis_id: gnis_id,
          geoid: row["GEOID"],
          fips_class: row["FIPS Class"],
          name: row["Name"],
          state: row["State"],
          county_geoid: row["County GEOID"],
          lat: row["Latitude"].to_f,
          lng: row["Longitude"].to_f,
          zcta: row["ZCTA"]
        }
      end

      gnis_places
    end

    private

    def add_counties(data)
      foreach(processed_file(Gnis::PLACE_COUNTIES_FILE), col_sep: ",") do |row|
        place_geoid = row["Place GEOID"]
        county_geoid = row["County GEOID"]

        place = data[place_geoid]
        next unless place

        place[:counties] << county_geoid unless place[:counties].include?(county_geoid)
      end
    end

    def add_urban_areas(places)
      overlaps = {}
      foreach(data_file(USGeoData::PLACE_URBAN_AREA_REL_FILE), col_sep: "|") do |row|
        urban_area_geoid = row["GEOID_UA_20"]
        place_geoid = row["GEOID_PLACE_20"]
        overlap_land_area = row["AREALAND_PART"].to_f * SQUARE_METERS_TO_MILES
        place_land_area = row["AREALAND_PLACE_20"].to_f * SQUARE_METERS_TO_MILES

        next unless urban_area_geoid && place_geoid && overlap_land_area > 0 && place_land_area > 0
        next unless places.include?(place_geoid)

        info = overlaps[place_geoid]
        unless info
          info = {}
          overlaps[place_geoid] = info
        end
        info[urban_area_geoid] = overlap_land_area / place_land_area
      end

      overlaps.each do |place_geoid, overlap|
        primary_urban_area = overlap.max_by { |_, percent| percent }.first
        places[place_geoid][:urban_area_geoid] = primary_urban_area
      end
    end

    def abbr_state(name)
      STATE_ABBREVIATIONS.each do |state, abbr|
        name = name.gsub(Regexp.new(state, Regexp::IGNORECASE), abbr)
      end
      name
    end

    def abbr_name(name, desired_length)
      ABBREVIATIONS.each do |pattern, replacement|
        break if name.size < desired_length
        name = name.gsub(pattern, replacement)
      end
      name
    end
  end
end
