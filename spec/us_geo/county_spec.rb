require 'spec_helper'

describe USGeo::County do

  describe "associations" do
    it "should have a state" do
      county = USGeo::County.new
      county.geoid = "00001"
      expect{ county.state }.to_not raise_error
      expect(county.build_state).to be_a(USGeo::State)
    end

    it "should have a core_based_statistical_area" do
      county = USGeo::County.new
      county.geoid = "00001"
      expect{ county.core_based_statistical_area }.to_not raise_error
      expect(county.build_core_based_statistical_area).to be_a(USGeo::CoreBasedStatisticalArea)
    end

    it "should have a metropolitan area if the core_based_statistical_area is metropolitan" do
      county = USGeo::County.new
      expect(county.metropolitan_area).to eq nil
      county.core_based_statistical_area = USGeo::MicropolitanArea.new
      expect(county.metropolitan_area).to eq nil
      metro_area = USGeo::MetropolitanArea.new
      county.core_based_statistical_area = metro_area
      expect(county.metropolitan_area).to eq metro_area
    end

    it "should have a metropolitan division" do
      county = USGeo::County.new
      county.geoid = "00001"
      expect{ county.metropolitan_division }.to_not raise_error
      expect(county.build_metropolitan_division).to be_a(USGeo::MetropolitanDivision)
    end

    it "should have zctas" do
      county = USGeo::County.new
      county.geoid = "00001"
      expect{ county.zctas }.to_not raise_error
      expect{ county.zcta_counties }.to_not raise_error
      expect(county.zcta_counties.build).to be_a(USGeo::ZctaCounty)
    end

    it "should have urban areas" do
      county = USGeo::County.new
      county.geoid = "00001"
      expect{ county.urban_areas }.to_not raise_error
      expect{ county.urban_area_counties }.to_not raise_error
      expect(county.urban_area_counties.build).to be_a(USGeo::UrbanAreaCounty)
    end

    it "should have places" do
      county = USGeo::County.new
      county.geoid = "00001"
      expect{ county.places }.to_not raise_error
      expect{ county.place_counties }.to_not raise_error
      expect(county.place_counties.build).to be_a(USGeo::PlaceCounty)
    end

    it "should have subdivisions" do
      county = USGeo::County.new
      county.geoid = "00001"
      expect{ county.subdivisions }.to_not raise_error
      expect(county.subdivisions.build).to be_a(USGeo::CountySubdivision)
    end

    it "should have a designated market area" do
      county = USGeo::County.new
      county.geoid = "00001"
      expect{ county.designated_market_area }.to_not raise_error
      expect(county.build_designated_market_area).to be_a(USGeo::DesignatedMarketArea)
    end
  end

  describe "load" do
    after { USGeo::County.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/counties.csv.gz", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/counties.csv.gz").to_return(body: data)
      USGeo::County.load!
      expect(USGeo::County.count).to be > 3000
      expect(USGeo::County.where(removed: true).count).to eq 0

      cook = USGeo::County.find("17031")
      expect(cook.name).to eq "Cook County"
      expect(cook.short_name).to eq "Cook"
      expect(cook.dma_code).to eq "602"
      expect(cook.cbsa_geoid).to eq "16980"
      expect(cook.state_code).to eq "IL"
      expect(cook.state_fips).to eq "17"
      expect(cook.county_fips).to eq "031"
      expect(cook.fips_class_code).to eq "H1"
      expect(cook.time_zone_name).to eq "America/Chicago"
      expect(cook.central?).to eq true
      expect(cook.population).to be > 5_000_000
      expect(cook.housing_units).to be > 2_000_000
      expect(cook.land_area.round).to eq 945
      expect(cook.water_area.round).to eq 690
      expect(cook.lat.round).to eq 42
      expect(cook.lng.round).to eq -88

      clinton = USGeo::County.find("17027")
      expect(clinton.name).to eq "Clinton County"
      expect(clinton.central?).to eq false
    end
  end

  describe "attributes" do
    it "should have a state FIPS code" do
      county = USGeo::County.new
      county.geoid = "17031"
      expect(county.state_fips).to eq "17"
    end

    it "should have a county FIPS code" do
      county = USGeo::County.new
      county.geoid = "17031"
      expect(county.county_fips).to eq "031"
    end

    it "should have a time zone" do
      county = USGeo::County.new(time_zone_name: "America/Chicago")
      expect(county.time_zone).to be_a(ActiveSupport::TimeZone)
      expect(county.time_zone.name).to eq "America/Chicago"
    end
  end

end
