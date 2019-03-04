# frozen_string_literal: true

module USGeo

  # Media market (DMA) as defined by the Nielsen Company.
  class DesignatedMarketArea < BaseRecord

    self.primary_key = "code"

    has_many :counties, foreign_key: :dma_code, inverse_of: :designated_market_area

    validates :code, length: {is: 3}
    validates :name, length: {maximum: 60}

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "dmas.csv.gz")
       
        mark_removed! do
          load_data_file(location) do |row|
            load_record!(code: row["Code"]) do |record|
              record.name = row["Name"]
            end
          end
        end
      end
    end

  end
end
