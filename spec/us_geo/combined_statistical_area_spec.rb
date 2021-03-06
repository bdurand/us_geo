require 'spec_helper'

describe USGeo::CombinedStatisticalArea do

  describe "associations" do
    it "should have core_based_statistical_areas" do
      csa = USGeo::CombinedStatisticalArea.new
      csa.geoid = "001"
      expect{ csa.core_based_statistical_areas }.to_not raise_error
      expect(csa.core_based_statistical_areas.build).to be_a(USGeo::CoreBasedStatisticalArea)
    end
  end

  describe "load" do
    after { USGeo::CombinedStatisticalArea.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/combined_statistical_areas.csv", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/combined_statistical_areas.csv").to_return(body: data, headers: {"Content-Type": "text/csv; charset=UTF-8"})
      USGeo::CombinedStatisticalArea.load!
      expect(USGeo::CombinedStatisticalArea.imported.count).to be > 150
      expect(USGeo::CombinedStatisticalArea.removed.count).to eq 0

      chicagoland = USGeo::CombinedStatisticalArea.find("176")
      expect(chicagoland.name).to eq "Chicago-Naperville, IL-IN-WI"
      expect(chicagoland.population).to be > 8_000_000
      expect(chicagoland.housing_units).to be > 3_000_000
      expect(chicagoland.land_area.round).to eq 10636
      expect(chicagoland.water_area.round).to eq 2431
    end
  end

end
