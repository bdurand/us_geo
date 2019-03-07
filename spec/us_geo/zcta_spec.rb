require 'spec_helper'

describe USGeo::Zcta do

  describe "associations" do
    it "should have a primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect{ zcta.primary_county }.to_not raise_error
      expect(zcta.build_primary_county).to be_a(USGeo::County)
    end

    it "should have counties" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect{ zcta.counties }.to_not raise_error
      expect{ zcta.zcta_counties }.to_not raise_error
      expect(zcta.zcta_counties.build).to be_a(USGeo::ZctaCounty)
    end

    it "should have a time zone via the primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      county = USGeo::County.new(time_zone_name: "America/Chicago")
      zcta.primary_county = county
      expect(zcta.time_zone).to eq ActiveSupport::TimeZone["America/Chicago"]
    end

    it "should have a state via the primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      state = USGeo::State.new
      state.code = "XX"
      county = USGeo::County.new(state_code: "XX")
      county.state = state
      zcta.primary_county = county
      expect(zcta.state_code).to eq "XX"
      expect(zcta.state).to eq state
    end

    it "should have a core based statistical area via the primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      cbsa = USGeo::CoreBasedStatisticalArea.new
      county = USGeo::County.new
      county.core_based_statistical_area = cbsa
      zcta.primary_county = county
      expect(zcta.core_based_statistical_area).to eq cbsa
    end

    it "should have a designated market area via the primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      dma = USGeo::DesignatedMarketArea.new
      county = USGeo::County.new
      county.designated_market_area = dma
      zcta.primary_county = county
      expect(zcta.designated_market_area).to eq dma
    end

    it "should have a primary urban area" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect{ zcta.primary_urban_area }.to_not raise_error
      expect(zcta.build_primary_urban_area).to be_a(USGeo::UrbanArea)
    end

    it "should have urban areas" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect{ zcta.urban_areas }.to_not raise_error
      expect{ zcta.zcta_urban_areas }.to_not raise_error
      expect(zcta.zcta_urban_areas.build).to be_a(USGeo::ZctaUrbanArea)
    end
  end

  describe "load" do
    after { USGeo::Zcta.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/zctas.csv.gz", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/zctas.csv.gz").to_return(body: data)
      USGeo::Zcta.load!
      expect(USGeo::Zcta.imported.count).to be > 30_000
      expect(USGeo::Zcta.removed.count).to eq 0

      zcta = USGeo::Zcta.find("60305")
      expect(zcta.primary_county_geoid).to eq "17031"
      expect(zcta.primary_urban_area_geoid).to eq "16264"
      expect(zcta.population).to be > 10_000
      expect(zcta.housing_units).to be > 4000
      expect(zcta.land_area.round(1)).to eq 2.5
      expect(zcta.water_area.round(3)).to eq 0.002
      expect(zcta.lat.round).to eq 42
      expect(zcta.lng.round).to eq -88
    end
  end

end
