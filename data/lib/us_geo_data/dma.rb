# frozen_string_literal: true

module USGeoData
  class Dma
    include Processor

    def initialize(counties: nil)
      @counties = nil
    end

    def dump_csv(output)
      CSV.new(output).tap do |csv|
        csv << ["Code", "Name", "Population", "Housing Units", "Land Area", "Water Area"]
        dma_data.each_value do |data|
          csv << [data[:code], data[:name], data[:population], data[:housing_units], data[:land_area].round(3), data[:water_area].round(3)]
        end
      end
      output
    end

    def dma_data
      unless defined?(@dma_data)
        data = {}

        foreach(data_file(USGeoData::DMAS_FILE)) do |row|
          data[row["Code"]] = {code: row["Code"], name: row["Name"], population: 0, housing_units: 0, land_area: 0.0, water_area: 0.0}
        end

        add_county_data(data)

        @dma_data = data
      end
      @dma_data
    end

    private

    def add_county_data(data)
      county_data.each_value do |county_data|
        dma_info = data[county_data[:dma_code]]
        next unless dma_info
        dma_info[:land_area] += county_data[:land_area].to_f
        dma_info[:water_area] += county_data[:water_area].to_f
        dma_info[:population] += county_data[:population].to_i
        dma_info[:housing_units] += county_data[:housing_units].to_i
      end
    end

    def county_data
      @counties ||= County.new
      @counties.county_data
    end
  end
end
