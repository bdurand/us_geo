# frozen_string_literal: true

module USGeoData
  class County
    include Processor

    def dump_csv(output)
      csv = CSV.new(output)
      csv << ["GEOID", "GNIS ID", "Name", "Short Name", "State", "CBSA", "Metropolitan Division", "Central", "DMA", "Time Zone", "FIPS Class", "Population", "Housing Units", "Land Area", "Water Area", "Latitude", "Longitude"]
      county_data.each_value do |data|
        unless data[:time_zone] && data[:gnis_id] && data[:fips_class]
          puts "Missing data for county #{data[:geoid]} #{data[:name]}, #{data[:state]}: #{data.inspect}"
          next
        end
        csv << [
          data[:geoid],
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
          data[:land_area]&.round(3),
          data[:water_area]&.round(3),
          data[:lat],
          data[:lng]
        ]
      end
      output
    end

    # Load info from all of the county data files into a hash by geoid.
    def county_data
      unless defined?(@county_data)
        counties = {}

        add_gnis_data(counties)
        add_county_info_data(counties)
        add_gazetteer_data(counties)
        add_cbsa_data(counties)
        add_demographics(counties)

        @county_data = counties
      end
      @county_data
    end

    private

    def add_gnis_data(counties)
      foreach(processed_file(Gnis::COUNTIES_FILE), col_sep: ",") do |row|
        counties[row["GEOID"]] = {
          geoid: row["GEOID"],
          gnis_id: row["GNIS ID"],
          fips_class: row["FIPS Class"],
          name: row["Name"],
          short_name: row["Short Name"],
          state: row["State"],
          lat: row["Latitude"]&.to_f,
          lng: row["Longitude"]&.to_f
        }
      end
    end

    def add_county_info_data(counties)
      foreach(data_file(USGeoData::COUNTY_INFO_FILE), col_sep: ",") do |row|
        county_geoid = row["GEOID"]
        data = counties[county_geoid]
        unless data
          puts row.to_h.inspect, "-" * 20
          data = {
            geoid: county_geoid,
            name: row["Full Name"],
            state: row["State"],
            fips_class: row["FIPS Class"]
          }
          counties[county_geoid] = data
        end

        data[:short_name] ||= row["Short Name"]
        data[:dma_code] = row["DMA Code"]
        data[:time_zone] = row["Time Zone"]
      end
    end

    def add_gazetteer_data(counties)
      foreach(data_file(USGeoData::COUNTY_GAZETTEER_FILE), col_sep: "\t") do |row|
        county_geoid = row["GEOID"]
        data = counties[county_geoid]
        unless data
          data = {
            geoid: county_geoid,
            name: row["Name"],
            state: row["USPS"]
          }
          counties[county_geoid] = data
        end
        data[:gnis_id] ||= row["ANSICODE"].gsub(/\A0+/, "").to_i
        data[:land_area] = row["ALAND_SQMI"]&.to_f
        data[:water_area] = row["AWATER_SQMI"]&.to_f
        data[:lat] ||= row["INTPTLAT"]&.to_f
        data[:lng] ||= row["INTPTLONG"]&.to_f
      end
    end

    def add_cbsa_data(counties)
      foreach(data_file(USGeoData::CBSA_DELINEATION_FILE), col_sep: ",") do |row|
        county_geoid = "#{row["FIPS State Code"]}#{row["FIPS County Code"]}"
        data = counties[county_geoid]
        if data
          data[:cbsa_code] = row["CBSA Code"]
          data[:metropolitan_division] = row["Metropolitan Division Code"]
          data[:central] = row["Central/Outlying County"].to_s.include?("Central")
          counties[county_geoid] = data
        end
      end
    end

    def add_demographics(counties)
      demographics(data_file(USGeoData::COUNTY_POPULATION_FILE)).each do |geoid, population|
        info = counties[geoid]
        info[:population] = population if info
      end

      demographics(data_file(USGeoData::COUNTY_HOUSING_UNITS_FILE)).each do |geoid, housing_units|
        info = counties[geoid]
        info[:housing_units] = housing_units if info
      end
    end
  end
end
