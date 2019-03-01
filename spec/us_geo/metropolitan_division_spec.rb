require 'spec_helper'

describe USGeo::MetropolitanDivision do

  describe "associations" do
    it "should have a core_based_statistical_area" do
      division = USGeo::MetropolitanDivision.new
      division.geoid = "00001"
      expect{ division.core_based_statistical_area }.to_not raise_error
      expect(division.build_core_based_statistical_area).to be_a(USGeo::CoreBasedStatisticalArea)
    end

    it "should have counties" do
      division = USGeo::MetropolitanDivision.new
      division.geoid = "00001"
      expect{ division.counties }.to_not raise_error
      expect(division.counties.build).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::MetropolitanDivision.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/metropolitan_divisions.csv.gz", __dir__))
      stub_request(:get, "#{USGeo::BaseRecord::BASE_DATA_URI}/metropolitan_divisions.csv.gz").to_return(body: data)
      USGeo::MetropolitanDivision.load!
      expect(USGeo::MetropolitanDivision.count).to be > 1
      expect(USGeo::MetropolitanDivision.where(removed: true).count).to eq 0

      division = USGeo::MetropolitanDivision.find("16984")
      expect(division.name).to eq "Chicago-Naperville-Evanston, IL"
      expect(division.cbsa_geoid).to eq "16980"
      expect(division.population).to be > 7_000_000
      expect(division.housing_units).to be > 2_000_000
      expect(division.land_area.round).to eq 3131
      expect(division.water_area.round).to eq 731
    end
  end

end
