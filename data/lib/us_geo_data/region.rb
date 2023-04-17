# frozen_string_literal: true

module USGeoData
  class Region
    include Processor

    class << self
      def name(id)
        unless defined?(@name_map)
          map = {}
          processor = new
          processor.foreach(processor.data_file(USGeoData::REGIONS_FILE)) do |row|
            map[row["ID"].to_i] = row["Name"]
          end
          @name_map = map
        end
        @name_map[id&.to_i]
      end
    end

    def initialize(states: nil)
      @states = states
    end

    def dump_csv(output)
      CSV.new(output).tap do |csv|
        csv << ["ID", "Name", "Population", "Housing Units", "Land Area", "Water Area"]
        region_data.each_value do |data|
          csv << [data[:id], data[:name], data[:population], data[:housing_units], data[:land_area].round(3), data[:water_area].round(3)]
        end
      end
      output
    end

    def region_data
      unless defined?(@region_data)
        data = {}
        foreach(data_file(USGeoData::REGIONS_FILE)) do |row|
          id = row["ID"].to_i
          data[id] = {id: id, name: row["Name"], population: 0, housing_units: 0, land_area: 0.0, water_area: 0.0}
        end

        add_state_values(data)

        @region_data = data
      end
      @region_data
    end

    private

    def add_state_values(data)
      state_data.each_value do |state_data|
        next unless state_data[:region_id]
        region_data = data[state_data[:region_id]]
        region_data[:population] += state_data[:population]
        region_data[:housing_units] += state_data[:housing_units]
        region_data[:land_area] += state_data[:land_area]
        region_data[:water_area] += state_data[:water_area]
      end
    end

    def state_data
      @states ||= USGeoData::State.new
      @states.state_data
    end
  end
end