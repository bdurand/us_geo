require "spec_helper"

describe USGeo::CombinedStatisticalArea do
  describe "associations" do
    it "should have core_based_statistical_areas" do
      csa = USGeo::CombinedStatisticalArea.new
      csa.geoid = "001"
      expect { csa.core_based_statistical_areas }.to_not raise_error
      expect(csa.core_based_statistical_areas.build).to be_a(USGeo::CoreBasedStatisticalArea)
    end
  end

  describe "load" do
    after { USGeo::CombinedStatisticalArea.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("combined_statistical_areas.csv")
      USGeo::CombinedStatisticalArea.load!
      expect(USGeo::CombinedStatisticalArea.imported.count).to be > 150
      expect(USGeo::CombinedStatisticalArea.removed.count).to eq 0

      chicagoland = USGeo::CombinedStatisticalArea.find("176")
      expect(chicagoland.name).to eq "Chicago-Naperville, IL-IN-WI"
      expect(chicagoland.population).to be_between(8_000_000, 12_000_000)
      expect(chicagoland.housing_units).to be_between(3_000_000, 5_000_000)
      expect(chicagoland.land_area.round).to be_between(9000, 12_000)
      expect(chicagoland.water_area.round).to be_between(1500, 2500)
    end
  end
end
