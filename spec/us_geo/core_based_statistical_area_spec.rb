# frozen_string_literal: true

require "spec_helper"

RSpec.describe USGeo::CoreBasedStatisticalArea do
  describe "associations" do
    it "should have a combined statistical area" do
      core_based_statistical_area = USGeo::CoreBasedStatisticalArea.new
      core_based_statistical_area.geoid = "00001"
      expect { core_based_statistical_area.combined_statistical_area }.to_not raise_error
      expect(core_based_statistical_area.build_combined_statistical_area).to be_a(USGeo::CombinedStatisticalArea)
    end

    it "should have counties" do
      core_based_statistical_area = USGeo::CoreBasedStatisticalArea.new
      core_based_statistical_area.geoid = "00001"
      expect { core_based_statistical_area.counties }.to_not raise_error
      expect(core_based_statistical_area.counties.build).to be_a(USGeo::County)
    end

    it "should have metropolitan divisions" do
      core_based_statistical_area = USGeo::CoreBasedStatisticalArea.new
      core_based_statistical_area.geoid = "00001"
      expect { core_based_statistical_area.metropolitan_divisions }.to_not raise_error
      expect(core_based_statistical_area.metropolitan_divisions.build).to be_a(USGeo::MetropolitanDivision)
    end
  end

  describe "load" do
    after { USGeo::CoreBasedStatisticalArea.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("core_based_statistical_areas.csv")

      USGeo::CoreBasedStatisticalArea.load!
      expect(USGeo::CoreBasedStatisticalArea.imported.count).to be > 900
      expect(USGeo::CoreBasedStatisticalArea.removed.count).to eq 0

      chicagoarea = USGeo::CoreBasedStatisticalArea.find("16980")
      expect(chicagoarea).to be_a(USGeo::MetropolitanArea)
      expect(chicagoarea.name).to eq "Chicago-Naperville-Elgin, IL-IN"
      expect(chicagoarea.short_name).to eq "Chicago, IL"
      expect(chicagoarea.csa_geoid).to eq "176"
      expect(chicagoarea.lat.round).to eq 42
      expect(chicagoarea.lng.round).to eq(-88)
      expect(chicagoarea.population).to be_between(8_000_000, 12_000_000)
      expect(chicagoarea.housing_units).to be_between(3_000_000, 5_000_000)
      expect(chicagoarea.land_area.round).to be_between(6500, 9000)
      expect(chicagoarea.water_area.round).to be_between(1500, 2500)

      centralia = USGeo::CoreBasedStatisticalArea.find("16460")
      expect(centralia.population).to be < 50_000
      expect(centralia).to be_a(USGeo::MicropolitanArea)
      expect(centralia.name).to eq "Centralia, IL"
    end
  end
end
