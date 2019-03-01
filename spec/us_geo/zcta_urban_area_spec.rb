require 'spec_helper'

describe USGeo::ZctaUrbanArea do

  it "should return the percentage of the population of the zcta is in the urban area" do
    zcta = USGeo::Zcta.new(population: 20_000)
    zcta_urban_area = zcta.zcta_counties.build(population: 5000)
    expect(zcta_urban_area.percent_population).to eq 0.25
  end

  it "should return the percentage of the land area of the zcta is in the urban area" do
    zcta = USGeo::Zcta.new(land_area: 200)
    zcta_urban_area = zcta.zcta_counties.build(land_area: 50)
    expect(zcta_urban_area.percent_land_area).to eq 0.25
  end

  it "should return the percentage of the total area of the zcta is in the urban area" do
    zcta = USGeo::Zcta.new(land_area: 150, water_area: 50)
    zcta_urban_area = zcta.zcta_counties.build(land_area: 30, water_area: 20)
    expect(zcta_urban_area.percent_total_area).to eq 0.25
  end

  describe "associations" do
    it "should have a zcta" do
      zcta_urban_area = USGeo::ZctaUrbanArea.new
      zcta_urban_area.zipcode = "60304"
      zcta_urban_area.urban_area_geoid = "0001"
      expect{ zcta_urban_area.zcta }.to_not raise_error
      expect(zcta_urban_area.build_zcta).to be_a(USGeo::Zcta)
    end

    it "should have an urban area" do
      zcta_urban_area = USGeo::ZctaUrbanArea.new
      zcta_urban_area.zipcode = "60304"
      zcta_urban_area.urban_area_geoid = "0001"
      expect{ zcta_urban_area.urban_area }.to_not raise_error
      expect(zcta_urban_area.build_urban_area).to be_a(USGeo::UrbanArea)
    end
  end

  describe "load" do
    after { USGeo::ZctaUrbanArea.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/zcta_urban_areas.csv.gz", __dir__))
      stub_request(:get, "#{USGeo::BaseRecord::BASE_DATA_URI}/zcta_urban_areas.csv.gz").to_return(body: data)
      USGeo::ZctaUrbanArea.load!
      expect(USGeo::ZctaUrbanArea.count).to be > 1
      zcta_urban_areas = USGeo::ZctaUrbanArea.where(urban_area_geoid: "39430")
      expect(zcta_urban_areas.size).to eq 5
      expect(zcta_urban_areas.collect(&:zipcode)).to match_array(["49423", "49424", "49434", "49460", "49464"])
      zcta_urban_area = zcta_urban_areas.detect{ |z| z.zipcode == "49423"}
      expect(zcta_urban_area.population).to be > 30_000
      expect(zcta_urban_area.housing_units).to be > 12_000
      expect(zcta_urban_area.land_area.round).to eq 20
      expect(zcta_urban_area.water_area.round(1)).to eq 1.5
    end
  end

end
