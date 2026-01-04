# frozen_string_literal: true

require "spec_helper"

RSpec.describe USGeo::MetropolitanDivision do
  describe "associations" do
    it "should have a core_based_statistical_area" do
      division = USGeo::MetropolitanDivision.new
      division.geoid = "00001"
      expect { division.core_based_statistical_area }.to_not raise_error
      expect(division.build_core_based_statistical_area).to be_a(USGeo::CoreBasedStatisticalArea)
    end

    it "should have counties" do
      division = USGeo::MetropolitanDivision.new
      division.geoid = "00001"
      expect { division.counties }.to_not raise_error
      expect(division.counties.build).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::MetropolitanDivision.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("metropolitan_divisions.csv")

      USGeo::MetropolitanDivision.load!
      expect(USGeo::MetropolitanDivision.imported.count).to be > 25
      expect(USGeo::MetropolitanDivision.removed.count).to eq 0

      division = USGeo::MetropolitanDivision.find("16984")
      expect(division.name).to eq "Chicago-Naperville-Schaumburg, IL"
      expect(division.cbsa_geoid).to eq "16980"
      expect(division.population).to be_between(7_000_000, 10_000_000)
      expect(division.housing_units).to be_between(2_000_000, 4_000_000)
      expect(division.land_area.round).to be_between(3000, 4000)
      expect(division.water_area.round).to be_between(500, 1000)
    end
  end
end
