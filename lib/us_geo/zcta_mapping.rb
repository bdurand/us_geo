# frozen_string_literal: true

module USGeo
  # Mapping of ZIP codes to currently active ZCTA's. The U.S. Postal Service
  # maintains the list of active ZIP codes which can change as population moves
  # around. New ZIP codes are created when a new area is developed and old ZIP
  # are retired when an area is losing population. The Census Bureau updates
  # the list of ZCTA's every 10 years.
  #
  # This mapping table allows looking up the current ZCTA for a ZIP code even
  # if that ZIP code was retired and is no longer in the ZCTA table.
  class ZctaMapping < BaseRecord
    self.table_name = "us_geo_zcta_mappings"
    self.primary_key = "zipcode"

    belongs_to :zcta, foreign_key: :zcta_zipcode, inverse_of: :zcta_mappings

    validates :zipcode, length: {is: 5}
    validates :zcta_zipcode, length: {is: 5}

    class << self
      def load!(uri = nil)
        location = data_uri(uri || "zcta_mappings.csv")

        import! do
          load_data_file(location) do |row|
            load_record!(zipcode: row["ZIP Code"]) do |record|
              record.zcta_zipcode = row["Active ZCTA5"]
            end
          end
        end
      end
    end
  end
end
