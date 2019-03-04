require 'spec_helper'

describe USGeo::ZctaCounty do

  describe "percentages" do
    it "should return the percentage of the population of the zcta" do
      zcta = USGeo::Zcta.new(population: 20_000)
      zcta_county = zcta.zcta_counties.build(population: 5000)
      expect(zcta_county.percent_zcta_population).to eq 0.25
    end

    it "should return the percentage of the land area of the zcta" do
      zcta = USGeo::Zcta.new(land_area: 200)
      zcta_county = zcta.zcta_counties.build(land_area: 50)
      expect(zcta_county.percent_zcta_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the zcta" do
      zcta = USGeo::Zcta.new(land_area: 150, water_area: 50)
      zcta_county = zcta.zcta_counties.build(land_area: 30, water_area: 20)
      expect(zcta_county.percent_zcta_total_area).to eq 0.25
    end

    it "should return the percentage of the population of the county" do
      county = USGeo::County.new(population: 20_000)
      zcta_county = county.zcta_counties.build(population: 5000)
      expect(zcta_county.percent_county_population).to eq 0.25
    end

    it "should return the percentage of the land area of the county" do
      county = USGeo::County.new(land_area: 200)
      zcta_county = county.zcta_counties.build(land_area: 50)
      expect(zcta_county.percent_county_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the county" do
      county = USGeo::County.new(land_area: 150, water_area: 50)
      zcta_county = county.zcta_counties.build(land_area: 30, water_area: 20)
      expect(zcta_county.percent_county_total_area).to eq 0.25
    end
  end

  describe "associations" do
    it "should have a zcta" do
      zcta_county = USGeo::ZctaCounty.new
      zcta_county.zipcode = "60304"
      zcta_county.county_geoid = "00001"
      expect{ zcta_county.zcta }.to_not raise_error
      expect(zcta_county.build_zcta).to be_a(USGeo::Zcta)
    end

    it "should have a county" do
      zcta_county = USGeo::ZctaCounty.new
      zcta_county.zipcode = "60304"
      zcta_county.county_geoid = "00001"
      expect{ zcta_county.county }.to_not raise_error
      expect(zcta_county.build_county).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::ZctaCounty.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/zcta_counties.csv.gz", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/zcta_counties.csv.gz").to_return(body: data)
      USGeo::ZctaCounty.load!
      expect(USGeo::ZctaCounty.count).to be > 40_000
      expect(USGeo::ZctaCounty.where(removed: true).count).to eq 0
      
      zcta_counties = USGeo::ZctaCounty.where(zipcode: "00601")
      expect(zcta_counties.size).to eq 2
      expect(zcta_counties.collect(&:county_geoid)).to match_array(["72001", "72141"])
      zcta_county = zcta_counties.detect{ |z| z.county_geoid == "72001"}
      expect(zcta_county.population).to be > 10_000
      expect(zcta_county.housing_units).to be > 4000
      expect(zcta_county.land_area.round).to eq 63
      expect(zcta_county.water_area.round(1)).to eq 0.3
    end
  end

end
