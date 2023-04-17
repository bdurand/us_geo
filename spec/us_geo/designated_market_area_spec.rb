require "spec_helper"

describe USGeo::DesignatedMarketArea do
  describe "associations" do
    it "should have counties" do
      division = USGeo::DesignatedMarketArea.new
      division.id = 1
      expect { division.counties }.to_not raise_error
      expect(division.counties.build).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::DesignatedMarketArea.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("dmas.csv")

      USGeo::DesignatedMarketArea.load!
      expect(USGeo::DesignatedMarketArea.imported.count).to be > 200
      expect(USGeo::DesignatedMarketArea.removed.count).to eq 0

      dma = USGeo::DesignatedMarketArea.find("602")
      expect(dma.name).to eq "Chicago, IL"
      expect(dma.population).to be_between(8_000_000, 12_000_000)
      expect(dma.housing_units).to be_between(3_000_000, 5_000_000)
      expect(dma.land_area.round).to be_between(9000, 10_000)
      expect(dma.water_area.round).to be_between(1500, 2500)
    end
  end
end
