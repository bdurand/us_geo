# frozen_string_literal: true

module USGeo
  # Media market (DMA) as defined by the Nielsen Company.
  class DesignatedMarketArea < BaseRecord
    include Population
    include Area

    self.primary_key = "code"

    has_many :counties, foreign_key: :dma_code, inverse_of: :designated_market_area

    validates :code, length: {is: 3}, uniqueness: true
    validates :name, presence: true, length: {maximum: 60}, uniqueness: true

    # @!attribute code
    #   @return [String] 3-digit code for the DMA.

    # @!attribute name
    #   @return [String] Name of the DMA.

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "dmas.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(code: row["Code"]) do |record|
              record.name = row["Name"]
              record.population = row["Population"]
              record.housing_units = row["Housing Units"]
              record.land_area = row["Land Area"]
              record.water_area = row["Water Area"]
            end
          end
        end
      end
    end
  end
end
