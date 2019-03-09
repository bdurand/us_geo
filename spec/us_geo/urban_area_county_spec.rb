require 'spec_helper'

describe USGeo::UrbanAreaCounty do

  describe "percentages" do
    it "should return the percentage of the population of the urban area" do
      urban_area = USGeo::UrbanArea.new(population: 20_000)
      urban_area_county = urban_area.urban_area_counties.build(population: 5000)
      expect(urban_area_county.percent_urban_area_population).to eq 0.25
    end

    it "should return the percentage of the land area of the urban area" do
      urban_area = USGeo::UrbanArea.new(land_area: 200)
      urban_area_county = urban_area.urban_area_counties.build(land_area: 50)
      expect(urban_area_county.percent_urban_area_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the urban area" do
      urban_area = USGeo::UrbanArea.new(land_area: 150, water_area: 50)
      urban_area_county = urban_area.urban_area_counties.build(land_area: 30, water_area: 20)
      expect(urban_area_county.percent_urban_area_total_area).to eq 0.25
    end

    it "should return the percentage of the population of the county" do
      county = USGeo::County.new(population: 20_000)
      urban_area_county = county.urban_area_counties.build(population: 5000)
      expect(urban_area_county.percent_county_population).to eq 0.25
    end

    it "should return the percentage of the land area of the county" do
      county = USGeo::County.new(land_area: 200)
      urban_area_county = county.urban_area_counties.build(land_area: 50)
      expect(urban_area_county.percent_county_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the county" do
      county = USGeo::County.new(land_area: 150, water_area: 50)
      urban_area_county = county.urban_area_counties.build(land_area: 30, water_area: 20)
      expect(urban_area_county.percent_county_total_area).to eq 0.25
    end
  end

  describe "associations" do
    it "should have a county" do
      urban_area_county = USGeo::UrbanAreaCounty.new
      urban_area_county.county_geoid = "60304"
      urban_area_county.urban_area_geoid = "00001"
      expect{ urban_area_county.county }.to_not raise_error
      expect(urban_area_county.build_county).to be_a(USGeo::County)
    end

    it "should have an urban area" do
      urban_area_county = USGeo::UrbanAreaCounty.new
      urban_area_county.county_geoid = "60304"
      urban_area_county.urban_area_geoid = "00001"
      expect{ urban_area_county.urban_area }.to_not raise_error
      expect(urban_area_county.build_urban_area).to be_a(USGeo::UrbanArea)
    end
  end

  describe "load" do
    after { USGeo::UrbanAreaCounty.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/urban_area_counties.csv", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/urban_area_counties.csv").to_return(body: data, headers: {"Content-Type": "text/csv; charset=UTF-8"})
      USGeo::UrbanAreaCounty.load!
      expect(USGeo::UrbanAreaCounty.imported.count).to be > 4000
      expect(USGeo::UrbanAreaCounty.removed.count).to eq 0

      urban_area_counties = USGeo::UrbanAreaCounty.where(urban_area_geoid: "39430")
      expect(urban_area_counties.size).to eq 2
      expect(urban_area_counties.collect(&:county_geoid)).to match_array(["26005", "26139"])
      urban_area_county = urban_area_counties.detect{ |z| z.county_geoid == "26005"}
      expect(urban_area_county.population).to be > 9000
      expect(urban_area_county.housing_units).to be > 4000
      expect(urban_area_county.land_area.round).to eq 8
      expect(urban_area_county.water_area.round(2)).to eq 0.03
    end
  end

end
