# frozen_string_literal: true

require 'csv'
require 'set'

module USGeo

  # This class is used to take raw or manipulated Census data files and export them as optimized
  # CSV files to match the database data structure that can then be loaded by the model `load!`
  # methods.
  #
  # The required files are (links are the current files as of 2019-02-22):
  #
  # Gazetteer files: https://www.census.gov/geo/maps-data/data/gazetteer2018.html
  # Relationship files: https://www.census.gov/geo/maps-data/data/relationship.html
  # CBSA Deliniation file: https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html
  # USGS GNIS names with federal codes: https://geonames.usgs.gov/domestic/download_data.htm
  class DataNormalizer

    def initialize(
        cbsa_gazetteer: "2018_Gaz_cbsa_national.txt",
        zcta_gazetteer: "2018_Gaz_zcta_national.txt",
        county_gazetteer: "2018_Gaz_counties_national.txt",
        subdivision_gazetteer: "2018_Gaz_cousubs_national.txt",
        place_gazetteer: "2018_Gaz_place_national.txt",
        ua_gazetteer: "2018_Gaz_ua_national.txt",
        cbsa_deliniation: "list1_Sep_2018.csv",
        zcta_county_rel: "zcta_county_rel_10.txt",
        zcta_cousub_rel: "zcta_cousub_rel_10.txt",
        zcta_place_rel: "zcta_place_rel_10.txt",
        ua_county_rel: "ua_county_rel_10.txt",
        ua_place_rel: "ua_place_rel_10.txt",
        ua_zcta_rel: "ua_zcta_rel_10.txt"
      )
      @base_dir = File.join(__dir__, "raw")
      @cbsa_gazetteer_file = File.join(@base_dir, cbsa_gazetteer)
      @county_gazetteer_file = File.join(@base_dir, county_gazetteer)
      @subdivision_gazetteer_file = File.join(@base_dir, subdivision_gazetteer)
      @place_gazetteer_file = File.join(@base_dir, place_gazetteer)
      @zcta_gazetteer_file = File.join(@base_dir, zcta_gazetteer)
      @ua_gazetteer_file = File.join(@base_dir, ua_gazetteer)
      @cbsa_deliniation_file = File.join(@base_dir, cbsa_deliniation)
      @zcta_county_rel_file = File.join(@base_dir, zcta_county_rel)
      @zcta_cousub_rel_file = File.join(@base_dir, zcta_cousub_rel)
      @zcta_place_rel_file = File.join(@base_dir, zcta_place_rel)
      @ua_county_rel_file = File.join(@base_dir, ua_county_rel)
      @ua_zcta_rel_file = File.join(@base_dir, ua_zcta_rel)
      @ua_place_rel_file = File.join(@base_dir, ua_place_rel)
    end

    def processed_dir
      File.expand_path("processed", __dir__)
    end

    def dump(dir = nil)
      dir ||= File.join(__dir__, "dist")
      File.open(File.join(dir, "combined_statistical_areas.csv"), "w") { |f| combined_statistical_areas(f) }
      File.open(File.join(dir, "core_based_statistical_areas.csv"), "w") { |f| core_based_statistical_areas(f) }
      File.open(File.join(dir, "metropolitan_divisions.csv"), "w") { |f| metropolitan_divisions(f) }
      File.open(File.join(dir, "counties.csv"), "w") { |f| counties(f) }
      File.open(File.join(dir, "county_subdivisions.csv"), "w") { |f| county_subdivisions(f) }
      File.open(File.join(dir, "places.csv"), "w") { |f| places(f) }
      File.open(File.join(dir, "zctas.csv"), "w") { |f| zctas(f) }
      File.open(File.join(dir, "urban_areas.csv"), "w") { |f| urban_areas(f) }

      zcta_list = Set.new
      foreach(File.join(dir, "zctas.csv"), headers: true) do |row|
        zcta_list << row["ZCTA5"]
      end

      urban_area_list = Set.new
      foreach(File.join(dir, "urban_areas.csv"), headers: true) do |row|
        urban_area_list << row["GEOID"]
      end

      county_list = Set.new
      foreach(File.join(dir, "counties.csv"), headers: true) do |row|
        county_list << row["GEOID"]
      end

      place_list = Set.new
      foreach(File.join(dir, "places.csv"), headers: true) do |row|
        place_list << row["GEOID"]
      end

      File.open(File.join(dir, "zcta_counties.csv"), "w") { |f| zcta_counties(f, zctas: zcta_list, counties: county_list) }
      File.open(File.join(dir, "zcta_urban_areas.csv"), "w") { |f| zcta_urban_areas(f, zctas: zcta_list, urban_areas: urban_area_list) }
      File.open(File.join(dir, "zcta_places.csv"), "w") { |f| zcta_places(f, zctas: zcta_list, places: place_list) }
      File.open(File.join(dir, "urban_area_counties.csv"), "w") { |f| urban_area_counties(f, urban_areas: urban_area_list, counties: county_list) }
      File.open(File.join(dir, "place_counties.csv"), "w") { |f| place_counties(f, places: place_list, counties: county_list) }
      nil
    end

    # Parse out the data from the USGS names with federal codes file into more manageable chunks.
    def parse_gnis_data(gnis_file)
      county_file = File.open(File.join(processed_dir, "gnis_counties.csv"), "w")
      subdivision_file = File.open(File.join(processed_dir, "gnis_subdivisions.csv"), "w")
      place_file = File.open(File.join(processed_dir, "gnis_places.csv"), "w")
      place_counties_file = File.open(File.join(processed_dir, "gnis_place_counties.csv"), "w")

      begin
        county_csv = CSV.new(county_file)
        subdivision_csv = CSV.new(subdivision_file)
        place_csv = CSV.new(place_file)
        place_counties_csv = CSV.new(place_counties_file)

        county_csv << ["GNIS ID", "GEOID", "Name", "Short Name", "State", "FIPS Class", "Latitude", "Longitude"]
        subdivision_csv << ["GNIS ID", "GEOID", "Name", "State", "FIPS Class", "County GEOID", "Latitude", "Longitude"]
        place_csv << ["GNIS ID", "GEOID", "Name", "State", "FIPS Class", "County GEOID", "Latitude", "Longitude"]
        place_counties_csv << ["Place GEOID", "County GEOID"]

        mapping = {
          "C1" => :place,
          "C2" => :place,
          "C3" => :place,
          "C4" => :place,
          "C5" => :place,
          "C6" => :place,
          "C7" => :place,
          "U1" => :place,
          "U2" => :place,
          "H1" => :county,
          "H5" => :county,
          "H6" => :county,
          "T1" => :subdivision,
          "T2" => :subdivision,
          "T5" => :subdivision
        }
        # TODO INACTIVE_CODES = ["C9", "H4", "T9"] or Z*
        foreach(gnis_file, headers: true, col_sep: "|") do |row|
          fips_class_code = row["CENSUS_CLASS_CODE"]
          classificaton = mapping[fips_class_code]
          next unless classificaton
          gnis_id = row["FEATURE_ID"].to_i
          name = row["FEATURE_NAME"]
          state_fips = row["STATE_NUMERIC"]
          state_code = row["STATE_ALPHA"]
          geoid = "#{state_fips}#{row['CENSUS_CODE']}"
          county_geoid = "#{state_fips}#{row['COUNTY_NUMERIC']}"
          lat = row["PRIMARY_LATITUDE"]
          lng = row["PRIMARY_LONGITUDE"]
          if classificaton == :county
            county_csv << [gnis_id, county_geoid, name, row["COUNTY_NAME"], state_code, fips_class_code, lat, lng]
          elsif classificaton == :subdivision
            geoid = "#{state_fips}#{row['COUNTY_NUMERIC']}#{row['CENSUS_CODE']}"
            subdivision_csv << [gnis_id, geoid, name, state_code, fips_class_code, county_geoid, lat, lng]
          elsif classificaton == :place
            county_num = row["COUNTY_SEQUENCE"].to_i
            if county_num == 1
              place_csv << [gnis_id, geoid, name, state_code, fips_class_code, county_geoid, lat, lng]
            end
            place_counties_csv << [geoid, county_geoid]
          end
        end
      ensure
        county_file.close
        subdivision_file.close
        place_file.close
        place_counties_file.close
      end
    end

    def combined_statistical_areas(output)
      combined_statistical_areas = {}
      foreach(@cbsa_deliniation_file, headers: true, col_sep: ",") do |row|
        csa_code = row["CSA Code"]
        next if csa_code.nil? || csa_code.empty?
        data = combined_statistical_areas[csa_code]
        unless data
          data = {name: row["CSA Title"], counties: Set.new, population: 0, housing_units: 0, land_area: 0, water_area: 0}
          combined_statistical_areas[csa_code] = data
        end
        county_geoid = "#{row['FIPS State Code']}#{row['FIPS County Code']}"
        data[:counties] << county_geoid
      end

      combined_statistical_areas.each do |code, data|
        data[:counties].each do |county_geoid|
          county_data = county_stats[county_geoid]
          data[:population] += county_data[:population]
          data[:housing_units] += county_data[:housing_units]
          data[:land_area] += county_data[:land_area]
          data[:water_area] += county_data[:water_area]
        end
      end

      csv = CSV.new(output)
      csv << ["GEOID", "Name", "Population", "Housing Units", "Land Area", "Water Area"]
      combined_statistical_areas.each do |geoid, data|
        csv << [geoid, data[:name], data[:population], data[:housing_units], data[:land_area], data[:water_area]]
      end
      output
    end

    def core_based_statistical_areas(output)
      core_based_statistical_areas = {}
      foreach(@cbsa_deliniation_file, headers: true, col_sep: ",") do |row|
        cbsa_code = row["CBSA Code"]
        data = core_based_statistical_areas[cbsa_code]
        unless data
          data = {name: row["CBSA Title"], counties: Set.new, population: 0, housing_units: 0, land_area: 0, water_area: 0}
          data[:csa] = row["CSA Code"]
          core_based_statistical_areas[cbsa_code] = data
        end
        county_geoid = "#{row['FIPS State Code']}#{row['FIPS County Code']}"
        data[:counties] << county_geoid
      end

      foreach(@cbsa_gazetteer_file, headers: true, col_sep: "\t") do |row|
        cbsa_geoid = row["GEOID"]
        data = core_based_statistical_areas[cbsa_geoid]
        if data
          data[:lat] = row["INTPTLAT"].to_f
          data[:lng] = row["INTPTLONG"].to_f
        end
      end

      core_based_statistical_areas.each do |code, data|
        data[:counties].each do |county_geoid|
          county_data = county_stats[county_geoid]
          data[:population] += county_data[:population]
          data[:housing_units] += county_data[:housing_units]
          data[:land_area] += county_data[:land_area]
          data[:water_area] += county_data[:water_area]
        end
        if data[:lat].nil? || data[:lng].nil?
          lats = []
          lngs = []
          foreach(@county_gazetteer_file, headers: true, col_sep: "\t") do |row|
            county_geoid = row["GEOID"]
            next unless data[:counties].include?(county_geoid)
            lats << row["INTPTLAT"].to_f
            lngs << row["INTPTLONG"].to_f
          end
          data[:lat] = lats.sum / lats.size
          data[:lng] = lngs.sum / lngs.size
        end
      end

      csv = CSV.new(output)
      csv << ["GEOID", "Name", "CSA", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      core_based_statistical_areas.each do |geoid, data|
        csv << [geoid, data[:name], data[:csa], data[:population], data[:housing_units], data[:land_area], data[:water_area], data[:lat], data[:lng]]
      end
      output
    end

    def metropolitan_divisions(output)
      metropolitan_divisions = {}
      foreach(@cbsa_deliniation_file, headers: true, col_sep: ",") do |row|
        division_code = row["Metropolitan Division Code"]
        next if division_code.nil? || division_code.empty?
        data = metropolitan_divisions[division_code]
        unless data
          data = {name: row["Metropolitan Division Title"], counties: Set.new, population: 0, housing_units: 0, land_area: 0, water_area: 0}
          data[:cbsa] = row["CBSA Code"]
          metropolitan_divisions[division_code] = data
        end
        county_geoid = "#{row['FIPS State Code']}#{row['FIPS County Code']}"
        data[:counties] << county_geoid
      end

      metropolitan_divisions.each do |code, data|
        data[:counties].each do |county_geoid|
          county_data = county_stats[county_geoid]
          data[:population] += county_data[:population]
          data[:housing_units] += county_data[:housing_units]
          data[:land_area] += county_data[:land_area]
          data[:water_area] += county_data[:water_area]
        end
      end

      csv = CSV.new(output)
      csv << ["GEOID", "Name", "CBSA", "Population", "Housing Units", "Land Area", "Water Area"]
      metropolitan_divisions.each do |geoid, data|
        csv << [geoid, data[:name], data[:cbsa], data[:population], data[:housing_units], data[:land_area], data[:water_area]]
      end
      output
    end

    def counties(output)
      counties = {}
      foreach(File.join(processed_dir, "gnis_counties.csv"), headers: true, col_sep: ",") do |row|
        counties[row["GEOID"]] = {
          gnis_id: row["GNIS ID"],
          fips_class: row["FIPS Class"],
          name: row["Name"],
          short_name: row["Short Name"],
          state: row["State"],
          lat: row["Latitude"].to_f,
          lng: row["Longitude"].to_f
        }
      end

      foreach(File.expand_path("processed/county_info.csv", __dir__), headers: true, col_sep: ",") do |row|
        county_geoid = row["GEOID"]
        data = counties[county_geoid]
        unless data
          data = {name: row["Full Name"], state: row["State"]}
          counties[county_geoid] = data
        end

        data[:short_name] ||= row["Short Name"]
        data[:dma_code] = row["DMA Code"]
        data[:time_zone] = row["Time Zone"]
        data[:fips_class] ||= row["FIPS Class"]
      end

      foreach(@county_gazetteer_file, headers: true, col_sep: "\t") do |row|
        county_geoid = row["GEOID"]
        data = counties[county_geoid]
        data[:gnis_id] ||= row["ANSICODE"].gsub(/\A0+/, '').to_i
        data[:land_area] = row["ALAND"].to_i
        data[:water_area] = row["AWATER"].to_i
        data[:lat] ||= row["INTPTLAT"].to_i
        data[:lng] ||= row["INTPTLONG"].to_i
      end

      foreach(@cbsa_deliniation_file, headers: true, col_sep: ",") do |row|
        county_geoid = "#{row['FIPS State Code']}#{row['FIPS County Code']}"
        data = counties[county_geoid]
        data[:cbsa_code] = row["CBSA Code"]
        data[:metropolitan_division] = row["Metropolitan Division Code"]
        data[:central] = row["Central/Outlying County"].to_s.include?("Central")
        counties[county_geoid] = data
      end

      counties.each do |county_geoid, data|
        county_data = county_stats[county_geoid]
        if county_data
          data[:population] = county_data[:population]
          data[:housing_units] = county_data[:housing_units]
          data[:land_area] = county_data[:land_area]
          data[:water_area] = county_data[:water_area]
        end
      end

      csv = CSV.new(output)
      csv << ["GEOID", "GNIS ID", "Name", "Short Name", "State", "CBSA", "Metropolitan Division", "Central", "DMA", "Time Zone", "FIPS Class", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      counties.each do |geoid, data|
        unless data[:time_zone] && data[:gnis_id] && data[:fips_class]
          puts "Missing data for county #{geoid} #{data[:name]}, #{data[:state]}: #{data.inspect}"
          next
        end
        csv << [
          geoid,
          data[:gnis_id],
          data[:name],
          data[:short_name],
          data[:state],
          data[:cbsa_code],
          data[:metropolitan_division],
          data[:central] ? "T" : "F",
          data[:dma_code],
          data[:time_zone],
          data[:fips_class],
          data[:population],
          data[:housing_units],
          data[:land_area],
          data[:water_area],
          data[:lat],
          data[:lng]
        ]
      end
      output
    end

    def county_subdivisions(output)
      subdivisions = {}
      foreach(File.join(processed_dir, "gnis_subdivisions.csv"), headers: true, col_sep: ",") do |row|
        subdivisions[row["GEOID"]] = {
          gnis_id: row["GNIS ID"],
          fips_class: row["FIPS Class"],
          name: row["Name"],
          county_geoid: row["County GEOID"],
          lat: row["Latitude"].to_f,
          lng: row["Longitude"].to_f
        }
      end

      foreach(@subdivision_gazetteer_file, headers: true, col_sep: "\t") do |row|
        geoid = row["GEOID"]
        data = subdivisions[geoid]
        unless data
          data = {name: row["NAME"], county_geoid: geoid[0, 5]}
          subdivisions[geoid] = data
        end
        data[:gnis_id] ||= row["ANSICODE"].gsub(/\A0+/, '').to_i
        data[:land_area] = row["ALAND"].to_i
        data[:water_area] = row["AWATER"].to_i
        data[:lat] ||= row["INTPTLAT"].to_i
        data[:lng] ||= row["INTPTLONG"].to_i
      end

      foreach(@zcta_cousub_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        data = subdivisions[row["GEOID"]]
        if data
          data[:fips_class] ||= row["CLASSFP"]
          data[:population] ||= row["CSPOP"].to_i
          data[:housing_units] ||= row["CSHU"].to_i
          data[:land_area] ||= row["CSAREALAND"].to_i
          data[:water_area] ||= row["CSAREA"].to_i - row["CSAREALAND"].to_i
        end
      end

      csv = CSV.new(output)
      csv << ["GEOID", "GNIS ID", "Name", "County GEOID", "FIPS Class", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      subdivisions.each do |geoid, data|
        unless data[:gnis_id] && data[:fips_class]
          puts "Missing data for subdivision #{geoid} #{data[:name]}: #{data.inspect}"
          next
        end
        csv << [
          geoid,
          data[:gnis_id],
          data[:name],
          data[:county_geoid],
          data[:fips_class],
          data[:population],
          data[:housing_units],
          data[:land_area],
          data[:water_area],
          data[:lat],
          data[:lng]
        ]
      end
      output
    end

    def places(output)
      places = {}
      foreach(File.join(processed_dir, "gnis_places.csv"), headers: true, col_sep: ",") do |row|
        places[row["GEOID"]] = {
          gnis_id: row["GNIS ID"],
          fips_class: row["FIPS Class"],
          name: row["Name"],
          state: row["State"],
          county_geoid: row["County GEOID"],
          lat: row["Latitude"].to_f,
          lng: row["Longitude"].to_f
        }
      end

      foreach(@place_gazetteer_file, headers: true, col_sep: "\t") do |row|
        geoid = row["GEOID"]
        data = places[geoid]
        unless data
          data = {name: row["NAME"], state: row["USPS"]}
          places[geoid] = data
        end
        data[:gnis_id] ||= row["ANSICODE"].gsub(/\A0+/, '').to_i
        data[:land_area] = row["ALAND"].to_i
        data[:water_area] = row["AWATER"].to_i
        data[:lat] ||= row["INTPTLAT"].to_i
        data[:lng] ||= row["INTPTLONG"].to_i
      end

      foreach(@zcta_place_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        data = places[row['GEOID']]
        if data
          data[:population] ||= row["PLPOP"].to_i
          data[:housing_units] ||= row["PLHU"].to_i
          data[:land_area] ||= row["PLAREALAND"].to_i
          data[:water_area] ||= row["PLAREA"].to_i - row["PLAREALAND"].to_i
        end
      end

      foreach(@ua_place_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        data = places[row['GEOID']]
        if data
          data[:urban_area_geoid] = row["UA"] unless row["UA"] == "99999"
        end
      end

      csv = CSV.new(output)
      csv << ["GEOID", "GNIS ID", "Name", "Short Name", "State", "County GEOID", "Urban Area GEOID", "FIPS Class", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      places.each do |geoid, data|
        unless data[:gnis_id] && data[:fips_class]
          puts "Missing data for place #{geoid} #{data[:name]}, #{data[:state]}: #{data.inspect}"
          next
        end
        short_name = data[:name]
        short_name = short_name.sub(/\A(The )?City and Borough of /i, "")
        short_name = short_name.sub(/\A(The )?Unified Government of /i, "")
        short_name = short_name.sub(/\A(The )?Consolidated Government of /i, "")
        short_name = short_name.sub(/\A(The )?City and County of /i, "")
        short_name = short_name.sub(/\A(The )?Metropolitan Government of /i, "")
        short_name = short_name.sub(/\A(The )?City of /i, "")
        short_name = short_name.sub(/\A(The )?Town of /i, "")
        short_name = short_name.sub(/\A(The )?Township of /i, "")
        short_name = short_name.sub(/\A(The )?Municipality of /i, "")
        short_name = short_name.sub(/\A(The )?Village of /i, "")
        short_name = short_name.sub(/\A(The )?Borough of /i, "")
        short_name = short_name.sub(/\A(The )?County of /i, "")
        short_name = short_name.sub(/\A(The )?Corporation of /i, "")
        short_name = short_name.sub(/ Census Designated Place/i, "")
        short_name = short_name.sub(/ CDP/i, "")
        short_name = short_name.sub(/ \(historical\)/i, "")
        short_name = short_name.sub(/ Township/i, "")
        short_name = short_name.sub(/ Consolidated Government/i, "")
        short_name = short_name.sub(/ Metro Government/i, "")
        short_name = short_name.sub(/ Comunidad\z/i, "")
        short_name = short_name.sub(/ Zona Urbana\z/i, "")

        short_name = short_name.sub(/\bUniversity\b/i, "Univ.") if short_name.size > 30
        short_name = short_name.split("-", 2).first if short_name.size > 30
        if short_name.size > 30
          raise "Short name for #{data[:name].inspect} greather than 30 characters: #{short_name.inspect}"
        end
        data[:short_name] = short_name
        csv << [
          geoid,
          data[:gnis_id],
          data[:name],
          data[:short_name],
          data[:state],
          data[:county_geoid],
          data[:urban_area_geoid],
          data[:fips_class],
          data[:population],
          data[:housing_units],
          data[:land_area],
          data[:water_area],
          data[:lat],
          data[:lng]
        ]
      end
      output
    end

    def zctas(output)
      zctas = {}
      foreach(@zcta_gazetteer_file, headers: true, col_sep: "\t") do |row|
        zcta5 = row["GEOID"]
        zctas[zcta5] = {
          population: 0,
          housing_units: 0,
          land_area: row["ALAND"].to_i,
          water_area: row["AWATER"].to_i,
          lat: row["INTPTLAT"].to_f,
          lng: row["INTPTLONG"].to_f
        }
      end

      zctas.each do |zcta5, data|
        zcta_data = zcta_stats[zcta5]
        if zcta_data
          data[:population] = zcta_data[:population]
          data[:housing_units] = zcta_data[:housing_units]
          data[:land_area] = zcta_data[:land_area]
          data[:water_area] = zcta_data[:water_area]
        end
      end

      csv = CSV.new(output)
      csv << ["ZCTA5", "Primary County", "Primary Urban Area", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      zctas.each do |zcta5, data|
        zcta_data = zcta_stats[zcta5]
        next unless zcta_data
        csv << [
          zcta5,
          zcta_data[:primary_county],
          zcta_data[:primary_urban_area],
          data[:population],
          data[:housing_units],
          data[:land_area],
          data[:water_area],
          data[:lat],
          data[:lng]
        ]
      end
      output
    end

    def urban_areas(output)
      areas = {}
      foreach(@ua_gazetteer_file, headers: true, col_sep: "\t") do |row|
        geoid = row["GEOID"]
        areas[geoid] = {
          name: row["NAME"],
          population: 0,
          housing_units: 0,
          land_area: row["ALAND"].to_i,
          water_area: row["AWATER"].to_i,
          lat: row["INTPTLAT"].to_f,
          lng: row["INTPTLONG"].to_f
        }
      end

      foreach(@ua_county_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        next unless row["UAPOP"]
        geoid = row["UA"]
        data = areas[geoid]
        unless data
          data = {
            name: row["UANAME"],
            land_area: row["UAAREALAND"].to_i,
            water_area: row["UAAREA"].to_i - row["UAAREALAND"].to_i,
          }
          areas[geoid] = data
        end
        data[:population] = row["UAPOP"]
        data[:housing_units] = row["UAHU"]
        data[:primary_county_pct] ||= 0
        if row["UAPOPPCT"].to_f >= data[:primary_county_pct]
          data[:primary_county] = row["GEOID"]
          data[:primary_county_pct] = row["UAPOPPCT"].to_f
        end
      end

      csv = CSV.new(output)
      csv << ["GEOID", "Name", "Primary County", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      areas.each do |geoid, data|
        csv << [
          geoid,
          data[:name],
          data[:primary_county],
          data[:population],
          data[:housing_units],
          data[:land_area],
          data[:water_area],
          data[:lat],
          data[:lng]
        ]
      end
      output
    end

    def zcta_counties(output, zctas: nil, counties: nil)
      csv = CSV.new(output)
      csv << ["ZCTA5", "GEOID", "Population", "Housing Units", "Land Area", "Water Area"]
      zcta_stats.each do |zcta5, zcta_data|
        zcta_data[:counties].each do |county_geoid, data|
          next if zctas && !zctas.include?(zcta5)
          next if counties && !counties.include?(county_geoid)
          csv << [
            zcta5,
            county_geoid,
            data[:population],
            data[:housing_units],
            data[:land_area],
            data[:water_area]
          ]
        end
      end
      output
    end

    def zcta_urban_areas(output, zctas: nil, urban_areas: nil)
      csv = CSV.new(output)
      csv << ["ZCTA5", "Urban Area GEOID", "Population", "Housing Units", "Land Area", "Water Area"]
      foreach(@ua_zcta_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        next unless row["UAPOP"]
        next if urban_areas && !urban_areas.include?(row["UA"])
        next if zctas && !zctas.include?(row["ZCTA5"])
        csv << [row["ZCTA5"], row["UA"], row["POPPT"], row["HUPT"], row["AREALANDPT"], row["AREAPT"].to_i - row["AREALANDPT"].to_i]
      end
      output
    end

    def zcta_places(output, zctas: nil, places: nil)
      csv = CSV.new(output)
      csv << ["ZCTA5", "Place GEOID", "Population", "Housing Units", "Land Area", "Water Area"]
      foreach(@zcta_place_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        next unless row["PLPOP"]
        next if places && !places.include?(row["GEOID"])
        next if zctas && !zctas.include?(row["ZCTA5"])
        csv << [row["ZCTA5"], row["GEOID"], row["POPPT"], row["HUPT"], row["AREALANDPT"], row["AREAPT"].to_i - row["AREALANDPT"].to_i]
      end
      output
    end

    def urban_area_counties(output, urban_areas: nil, counties: nil)
      csv = CSV.new(output)
      csv << ["Urban Area GEOID", "County GEOID", "Population", "Housing Units", "Land Area", "Water Area"]
      foreach(@ua_county_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        next unless row["UAPOP"]
        next if urban_areas && !urban_areas.include?(row["UA"])
        next if counties && !counties.include?(row["GEOID"])
        csv << [row["UA"], row["GEOID"], row["POPPT"], row["HUPT"], row["AREALANDPT"], row["AREAPT"].to_i - row["AREALANDPT"].to_i]
      end
      output
    end

    def place_counties(output, places: nil, counties: nil)
      csv = CSV.new(output)
      csv << ["Place GEOID", "County GEOID"]
      foreach(File.join(processed_dir, "gnis_place_counties.csv"), headers: true, col_sep: ",") do |row|
        next if places && !places.include?(row["Place GEOID"])
        next if counties && !counties.include?(row["County GEOID"])
        csv << [row["Place GEOID"], row["County GEOID"]]
      end
      output
    end

    private

    def county_stats
      unless defined?(@county_stats)
        data = {}
        foreach(@zcta_county_rel_file, headers: true, col_sep: ",") do |row|
          geoid = row["GEOID"]
          next if data.include?(geoid)
          population = row["COPOP"].to_i
          housing_units = row["COHU"].to_i
          land_area = row["COAREALAND"].to_i
          water_area = row["COAREA"].to_i - land_area
          data[geoid] = {population: population, housing_units: housing_units, land_area: land_area, water_area: water_area}
        end
        @county_stats = data
      end
      @county_stats
    end

    def zcta_stats
      unless defined?(@zcta_stats)
        data = {}
        foreach(@zcta_county_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
          zcta5 = row["ZCTA5"]
          zcta_data = data[zcta5]
          next unless row["ZPOP"]
          unless zcta_data
            zcta_data = {
              population: row["ZPOP"].to_i,
              housing_units: row["ZHU"].to_i,
              land_area: row["ZAREALAND"].to_i,
              water_area: row["ZAREA"].to_i - row["ZAREALAND"].to_i,
              counties: {}
            }
            data[zcta5] = zcta_data
          end
          county_geoid = row["GEOID"]
          zcta_data[:primary_county_pct] ||= 0
          if row["ZPOPPCT"].to_f >= zcta_data[:primary_county_pct]
            zcta_data[:primary_county] = county_geoid
            zcta_data[:primary_county_pct] = row["ZPOPPCT"].to_f
          end
          zcta_data[:counties][county_geoid] = {
            population: row["POPPT"].to_i,
            housing_units: row["HUPT"].to_i,
            land_area: row["AREALANDPT"].to_i,
            water_area: row["AREAPT"].to_i - row["AREALANDPT"].to_i
          }
        end

        foreach(@ua_zcta_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
          zcta5 = row["ZCTA5"]
          zcta_data = data[zcta5]
          next unless zcta_data && row["ZPOP"]
          zcta_data[:primary_ua_pct] ||= 0
          if row["ZPOPPCT"].to_f >= zcta_data[:primary_ua_pct]
            zcta_data[:primary_urban_area] = row["UA"] unless row["UA"] == "99999"
            zcta_data[:primary_ua_pct] = row["ZPOPPCT"].to_f
          end
        end

        @zcta_stats = data
      end
      @zcta_stats
    end

    def foreach(csv_file, options = {}, &block)
      options = options.dup
      encoding = options.delete(:encoding) || "UTF-8"
      file = (csv_file.is_a?(String) ? File.open(csv_file, encoding: encoding) : csv_file)
      begin
        # Skip the BOM bytes if the file was exported as UTF-8 CSV from Excel
        bytes = file.read(3)
        file.rewind unless bytes == "\xEF\xBB\xBF".b
        CSV.new(file, options).each(&block)
      ensure
        file.close if csv_file.is_a?(String)
      end
    end
  end
end
