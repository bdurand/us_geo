# frozen_string_literal: true

module USGeoData
  class State
    include Processor

    def initialize(counties: nil)
      @counties = nil
    end

    def dump_csv(output)
      CSV.new(output).tap do |csv|
        csv << ["Name", "Code", "Type", "FIPS", "Region ID", "Region", "Division ID", "Division", "Population", "Housing Units", "Land Area", "Water Area"]
        state_data.each_value do |data|
          csv << [
            data[:name],
            data[:code],
            data[:type],
            data[:fips],
            data[:region_id],
            USGeoData::Region.name(data[:region_id]),
            data[:division_id],
            USGeoData::Division.name(data[:division_id]),
            ((data[:population] == 0) ? nil : data[:population]),
            ((data[:housing_units] == 0) ? nil : data[:housing_units]),
            data[:land_area].round(3),
            data[:water_area].round(3)
          ]
        end
      end
      output
    end

    def state_data
      unless defined?(@state_data)
        data = {}
        code_to_name = {}
        foreach(data_file(USGeoData::STATES_FILE)) do |row|
          code_to_name[row["Code"]] = row["Name"]
          data[row["Name"]] = {
            name: row["Name"],
            code: row["Code"],
            type: row["Type"],
            fips: row["FIPS"],
            division_id: row["Division ID"]&.to_i,
            region_id: row["Region ID"]&.to_i,
            population: 0,
            housing_units: 0
          }
        end

        foreach(data_file(USGeoData::STATE_DATA_FILE)) do |row|
          data[row["State"]][:land_area] ||= row["Land Square Miles"].to_f
          data[row["State"]][:water_area] ||= row["Water Square Miles"].to_f
        end

        add_county_data(data, code_to_name)

        @state_data = data
      end
      @state_data
    end

    private

    def add_county_data(data, code_to_name)
      county_data.each_value do |county|
        state_name = code_to_name[county[:state]]
        data[state_name][:population] += county[:population].to_i
        data[state_name][:housing_units] += county[:housing_units].to_i
      end
    end

    def county_data
      @counties ||= County.new
      @counties.county_data
    end
  end
end
