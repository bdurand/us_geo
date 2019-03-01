# frozen_string_literal: true

require 'csv'
require 'set'
require 'zlib'

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
  class DataNormalizer

    def initialize(
        cbsa_gazetteer: "2018_Gaz_cbsa_national.txt",
        zcta_gazetteer: "2018_Gaz_zcta_national.txt",
        county_gazetteer: "2018_Gaz_counties_national.txt",
        ua_gazetteer: "2018_Gaz_ua_national.txt",
        cbsa_deliniation: "list1_Sep_2018.csv",
        zcta_county_rel: "zcta_county_rel_10.txt",
        ua_county_rel: "ua_county_rel_10.txt",
        ua_zcta_rel: "ua_zcta_rel_10.txt"
      )
      @base_dir = File.join(__dir__, "raw")
      @cbsa_gazetteer_file = File.join(@base_dir, cbsa_gazetteer)
      @county_gazetteer_file = File.join(@base_dir, county_gazetteer)
      @zcta_gazetteer_file = File.join(@base_dir, zcta_gazetteer)
      @ua_gazetteer_file = File.join(@base_dir, ua_gazetteer)
      @cbsa_deliniation_file = File.join(@base_dir, cbsa_deliniation)
      @zcta_county_rel_file = File.join(@base_dir, zcta_county_rel)
      @ua_county_rel_file = File.join(@base_dir, ua_county_rel)
      @ua_zcta_rel_file = File.join(@base_dir, ua_zcta_rel)
    end

    def dump(dir = nil)
      dir ||= File.join(__dir__, "dist")
      gzip(File.join(dir, "combined_statistical_areas.csv.gz")) { |f| combined_statistical_areas(f) }
      gzip(File.join(dir, "core_based_statistical_areas.csv.gz")) { |f| core_based_statistical_areas(f) }
      gzip(File.join(dir, "metropolitan_divisions.csv.gz")) { |f| metropolitan_divisions(f) }
      gzip(File.join(dir, "counties.csv.gz")) { |f| counties(f) }
      gzip(File.join(dir, "zctas.csv.gz")) { |f| zctas(f) }
      gzip(File.join(dir, "urban_areas.csv.gz")) { |f| urban_areas(f) }
      gzip(File.join(dir, "zcta_counties.csv.gz")) { |f| zcta_counties(f) }
      gzip(File.join(dir, "zcta_urban_areas.csv.gz")) { |f| zcta_urban_areas(f) }
      gzip(File.join(dir, "urban_area_counties.csv.gz")) { |f| urban_area_counties(f) }
      nil
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
    end

    def counties(output)
      counties = {}
      foreach(@county_gazetteer_file, headers: true, col_sep: "\t") do |row|
        county_geoid = row["GEOID"]
        counties[county_geoid] = {
          name: row["NAME"],
          population: 0,
          housing_units: 0,
          land_area: row["ALAND"].to_i,
          water_area: row["AWATER"].to_i,
          state: row["USPS"],
          lat: row["INTPTLAT"].to_f,
          lng: row["INTPTLONG"].to_f
        }
      end

      foreach(@cbsa_deliniation_file, headers: true, col_sep: ",") do |row|
        county_geoid = "#{row['FIPS State Code']}#{row['FIPS County Code']}"
        data = counties[county_geoid]
        data[:cbsa_code] = row["CBSA Code"]
        data[:central] = row["Central/Outlying County"].to_s.include?("Central")
        counties[county_geoid] = data
      end

      foreach(File.join(@base_dir, "county_info.csv"), headers: true, col_sep: ",") do |row|
        county_geoid = row["GEOID"]
        data = counties[county_geoid]
        if data
          data[:short_name] = row["Short Name"]
          data[:dma_code] = row["DMA Code"]
          data[:time_zone] = row["Time Zone"]
          data[:fips_class] = row["FIPS Class"]
        else
          raise "Missing #{row.inspect}" unless ["GU", "AS", "MP", "VI"].include?(row["State"])
        end
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
      csv << ["GEOID", "Name", "Short Name", "State", "CBSA", "Central", "DMA", "Time Zone", "FIPS Class", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      counties.each do |geoid, data|
        unless data[:time_zone]
          raise "Missing time zone for #{geoid} #{data[:name]}, #{data[:state]}"
        end
        csv << [
          geoid,
          data[:name],
          data[:short_name],
          data[:state],
          data[:cbsa_code],
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
    end

    def zcta_counties(output)
      csv = CSV.new(output)
      csv << ["ZCTA5", "GEOID", "Population", "Housing Units", "Land Area", "Water Area"]
      zcta_stats.each do |zcta5, zcta_data|
        zcta_data[:counties].each do |county_geoid, data|
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
    end

    def zcta_urban_areas(output)
      csv = CSV.new(output)
      csv << ["ZCTA5", "Urban Area GEOID", "Population", "Housing Units", "Land Area", "Water Area"]
      foreach(@ua_zcta_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        next unless row["UAPOP"]
        csv << [row["ZCTA5"], row["UA"], row["POPPT"], row["HUPT"], row["AREALANDPT"], row["AREAPT"].to_i - row["AREALANDPT"].to_i]
      end
    end

    def urban_area_counties(output)
      csv = CSV.new(output)
      csv << ["Urban Area GEOID", "County GEOID", "Population", "Housing Units", "Land Area", "Water Area"]
      foreach(@ua_county_rel_file, headers: true, col_sep: ",", encoding: "iso8859-1") do |row|
        next unless row["UAPOP"]
        csv << [row["UA"], row["GEOID"], row["POPPT"], row["HUPT"], row["AREALANDPT"], row["AREAPT"].to_i - row["AREALANDPT"].to_i]
      end
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
          if row["ZPOPPCT"].to_f >= zcta_data[:primary_ua_pct] && row["UA"] != "99999"
            zcta_data[:primary_urban_area] = row["UA"]
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
      File.open(csv_file, encoding: encoding) do |file|
        # Skip the BOM bytes if the file was exported as UTF-8 CSV from Excel
        bytes = file.read(3)
        file.rewind unless bytes == "\xEF\xBB\xBF".b
        CSV.new(file, options).each(&block)
      end
    end

    def gzip(path, &block)
      Zlib::GzipWriter.open(path, Zlib::BEST_COMPRESSION, &block)
    end
  end
end
