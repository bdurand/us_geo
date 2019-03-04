require 'spec_helper'

describe USGeo::CoreBasedStatisticalArea do

  describe "associations" do
    it "should have a combined statistical area" do
      core_based_statistical_area = USGeo::CoreBasedStatisticalArea.new
      core_based_statistical_area.geoid = "00001"
      expect{ core_based_statistical_area.combined_statistical_area }.to_not raise_error
      expect(core_based_statistical_area.build_combined_statistical_area).to be_a(USGeo::CombinedStatisticalArea)
    end

    it "should have counties" do
      core_based_statistical_area = USGeo::CoreBasedStatisticalArea.new
      core_based_statistical_area.geoid = "00001"
      expect{ core_based_statistical_area.counties }.to_not raise_error
      expect(core_based_statistical_area.counties.build).to be_a(USGeo::County)
    end

    it "should have metropolitan divisions" do
      core_based_statistical_area = USGeo::CoreBasedStatisticalArea.new
      core_based_statistical_area.geoid = "00001"
      expect{ core_based_statistical_area.metropolitan_divisions }.to_not raise_error
      expect(core_based_statistical_area.metropolitan_divisions.build).to be_a(USGeo::MetropolitanDivision)
    end
  end

  describe "load" do
    after { USGeo::CoreBasedStatisticalArea.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/core_based_statistical_areas.csv.gz", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/core_based_statistical_areas.csv.gz").to_return(body: data)
      USGeo::CoreBasedStatisticalArea.load!
      expect(USGeo::CoreBasedStatisticalArea.count).to be > 900
      expect(USGeo::CoreBasedStatisticalArea.where(removed: true).count).to eq 0

      chicagoarea = USGeo::CoreBasedStatisticalArea.find("16980")
      expect(chicagoarea).to be_a(USGeo::MetropolitanArea)
      expect(chicagoarea.name).to eq "Chicago-Naperville-Elgin, IL-IN-WI"
      expect(chicagoarea.csa_geoid).to eq "176"
      expect(chicagoarea.population).to be > 8_000_000
      expect(chicagoarea.housing_units).to be > 3_000_000
      expect(chicagoarea.land_area.round).to eq 7197
      expect(chicagoarea.water_area.round).to eq 2382
      expect(chicagoarea.lat.round).to eq 42
      expect(chicagoarea.lng.round).to eq -88

      centralia = USGeo::CoreBasedStatisticalArea.find("16460")
      expect(centralia.population).to be < 50_000
      expect(centralia).to be_a(USGeo::MicropolitanArea)
      expect(centralia.name).to eq "Centralia, IL"
    end
  end

end
