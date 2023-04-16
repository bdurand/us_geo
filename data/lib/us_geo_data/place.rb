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
      /( Census)? Designated Place/i,
      / CDP/i,
      / \(historical\)/i,
      / \(balance\)/i,
      / Township/i,
      / Consolidated Government/i,
      / Metro Government/i,
      / Comunidad\z/i,
      / Zona Urbana\z/i
    ].freeze

    ABBREVIATE_IN_SHORT_NAME = {
      /\b(The )?University\b/i => "Univ.",
      /\bInstitute\b/i => "Inst.",
      /\bCollege\b/i => "Coll."
    }.freeze

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "GNIS ID", "Name", "Short Name", "State", "County GEOID", "FIPS Class", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      place_data.each_value do |data|
        unless data[:gnis_id] && data[:fips_class]
          puts "Missing data for place #{data[:geoid]} #{data[:name]}, #{data[:state]}: #{data.inspect}"
          next
        end
        csv << [
          data[:geoid],
          data[:gnis_id],
          data[:name],
          data[:short_name],
          data[:state],
          data[:county_geoid],
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
        foreach(data_file(USGeoData::PLACE_GAZETTEER_FILE), col_sep: "\t") do |row|
          geoid = row["GEOID"]
          gnis_id ||= row["ANSICODE"].gsub(/\A0+/, "").to_i
          data = gnis_places[gnis_id].dup
          data ||= {
            name: row["NAME"],
            short_name: short_name(row["NAME"]),
            state: row["USPS"],
            gnis_id: gnis_id
          }
          data[:geoid] = geoid
          data[:land_area] = row["ALAND_SQMI"]&.to_f
          data[:water_area] = row["AWATER_SQMI"]&.to_f
          data[:lat] ||= row["INTPTLAT"]&.to_f
          data[:lng] ||= row["INTPTLONG"]&.to_f
          data[:counties] = [data[:county_geoid]].compact
          places[geoid] = data
        end

        add_demographics(places)
        add_counties(places)

        @place_data ||= places
      end
      @place_data
    end

    def short_name(name)
      short_name = name
      STRIP_FROM_SHORT_NAME.each do |pattern|
        short_name = short_name.sub(pattern, "")
      end

      ABBREVIATE_IN_SHORT_NAME.each do |pattern, replacement|
        short_name = short_name.gsub(pattern, replacement) if short_name.size > 30
      end

      short_name = abbr_state(short_name) if short_name.size > 30

      short_name = short_name.split("-", 2).first if short_name.size > 30

      if short_name.size > 30
        raise "Short name for #{name} greather than 30 characters: #{short_name.inspect} (#{short_name.size} characters)"
      end

      short_name
    end

    private

    def add_demographics(places)
      demographics(data_file(USGeoData::PLACE_POPULATION_FILE)).each do |geoid, population|
        info = places[geoid]
        info[:population] = population if info
      end

      demographics(data_file(USGeoData::PLACE_HOUSING_UNITS_FILE)).each do |geoid, housing_units|
        info = places[geoid]
        info[:housing_units] = housing_units if info
      end
    end

    def add_counties(data)
      foreach(processed_file(Gnis::PLACE_COUNTIES_FILE), col_sep: ",") do |row|
        place_geoid = row["Place GEOID"]
        county_geoid = row["County GEOID"]

        place = data[place_geoid]
        next unless place

        place[:counties] << county_geoid unless place[:counties].include?(county_geoid)
      end
    end

    def abbr_state(name)
      STATE_ABBREVIATIONS.each do |state, abbr|
        name = name.gsub(Regexp.new(state, Regexp::IGNORECASE), abbr)
      end
      name
    end

    def gnis_place_mapping
      gnis_places = {}
      foreach(processed_file(Gnis::PLACES_FILE), col_sep: ",") do |row|
        gnis_id = row["GNIS ID"].to_i
        gnis_places[gnis_id] = {
          gnis_id: gnis_id,
          fips_class: row["FIPS Class"],
          name: row["Name"],
          state: row["State"],
          county_geoid: row["County GEOID"],
          lat: row["Latitude"].to_f,
          lng: row["Longitude"].to_f
        }
      end
      gnis_places
    end
  end
end
