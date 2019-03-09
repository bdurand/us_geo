require 'spec_helper'

describe USGeo::UrbanArea do

  describe "associations" do
    it "should have zctas" do
      urban_area = USGeo::UrbanArea.new
      urban_area.geoid = "00001"
      expect{ urban_area.zctas }.to_not raise_error
      expect{ urban_area.zcta_urban_areas }.to_not raise_error
      expect(urban_area.zcta_urban_areas.build).to be_a(USGeo::ZctaUrbanArea)
    end

    it "should have counties" do
      urban_area = USGeo::UrbanArea.new
      urban_area.geoid = "00001"
      expect{ urban_area.counties }.to_not raise_error
      expect{ urban_area.urban_area_counties }.to_not raise_error
      expect(urban_area.urban_area_counties.build).to be_a(USGeo::UrbanAreaCounty)
    end

    it "should have a primary county" do
      urban_area = USGeo::UrbanArea.new
      urban_area.geoid = "00001"
      expect{ urban_area.primary_county }.to_not raise_error
      expect(urban_area.build_primary_county).to be_a(USGeo::County)
    end

    it "should have a time zone via the primary county" do
      urban_area = USGeo::UrbanArea.new
      county = USGeo::County.new(time_zone_name: "America/Chicago")
      urban_area.primary_county = county
      expect(urban_area.time_zone).to eq ActiveSupport::TimeZone["America/Chicago"]
    end

    it "should have a state via the primary county" do
      urban_area = USGeo::UrbanArea.new
      state = USGeo::State.new
      state.code = "XX"
      county = USGeo::County.new(state_code: "XX")
      county.state = state
      urban_area.primary_county = county
      expect(urban_area.state_code).to eq "XX"
      expect(urban_area.state).to eq state
    end

    it "should have a core based statistical area via the primary county" do
      urban_area = USGeo::UrbanArea.new
      cbsa = USGeo::CoreBasedStatisticalArea.new
      county = USGeo::County.new
      county.core_based_statistical_area = cbsa
      urban_area.primary_county = county
      expect(urban_area.core_based_statistical_area).to eq cbsa
    end

    it "should have a designated market area via the primary county" do
      urban_area = USGeo::UrbanArea.new
      dma = USGeo::DesignatedMarketArea.new
      county = USGeo::County.new
      county.designated_market_area = dma
      urban_area.primary_county = county
      expect(urban_area.designated_market_area).to eq dma
    end

  end

  describe "load" do
    after { USGeo::UrbanArea.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/urban_areas.csv", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/urban_areas.csv").to_return(body: data, headers: {"Content-Type": "text/csv; charset=UTF-8"})
      USGeo::UrbanArea.load!
      expect(USGeo::UrbanArea.imported.count).to be > 3500
      expect(USGeo::UrbanArea.removed.count).to eq 0

      chicago = USGeo::UrbanizedArea.find("16264")
      expect(chicago.name).to eq "Chicago, IL--IN Urbanized Area"
      expect(chicago.short_name).to eq "Chicago, IL--IN"
      expect(chicago.primary_county_geoid).to eq "17031"
      expect(chicago.population).to be > 8_000_000
      expect(chicago.housing_units).to be > 3_000_000
      expect(chicago.land_area.round).to eq 2441
      expect(chicago.water_area.round).to eq 43
      expect(chicago.lat.round).to eq 42
      expect(chicago.lng.round).to eq -88
      expect(chicago.urbanized?).to eq true
      expect(chicago.cluster?).to eq false

      clinton = USGeo::UrbanCluster.find("17884")
      expect(clinton.name).to eq "Clinton, IL Urban Cluster"
      expect(clinton.short_name).to eq "Clinton, IL"
      expect(chicago.urbanized?).to eq true
      expect(chicago.cluster?).to eq false
    end
  end

end
