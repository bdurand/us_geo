require "spec_helper"

describe USGeo::Place do

  describe "associations" do
    it "should have a state" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect{ place.state }.to_not raise_error
      expect(place.build_state).to be_a(USGeo::State)
    end

    it "should have a primary county" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect{ place.primary_county }.to_not raise_error
      expect(place.build_primary_county).to be_a(USGeo::County)
    end

    it "should have an urban area" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect{ place.urban_area }.to_not raise_error
      expect(place.build_urban_area).to be_a(USGeo::UrbanArea)
    end

    it "should have counties" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect{ place.counties }.to_not raise_error
      expect{ place.place_counties }.to_not raise_error
      expect(place.place_counties.build).to be_a(USGeo::PlaceCounty)
    end

    it "should have zctas" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect{ place.zctas }.to_not raise_error
      expect{ place.zcta_places }.to_not raise_error
      expect(place.zcta_places.build).to be_a(USGeo::ZctaPlace)
    end
  end

  describe "load" do
    after { USGeo::Place.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/places.csv.gz", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/places.csv.gz").to_return(body: data)
      USGeo::Place.load!
      expect(USGeo::Place.imported.count).to be > 30_000
      expect(USGeo::Place.removed.count).to eq 0

      place = USGeo::Place.find("0649187")
      expect(place.gnis_id).to eq 2413013
      expect(place.name).to eq "Town of Moraga"
      expect(place.short_name).to eq "Moraga"
      expect(place.state_code).to eq "CA"
      expect(place.primary_county_geoid).to eq "06013"
      expect(place.urban_area_geoid).to eq "19504"
      expect(place.population).to be > 15_000
      expect(place.housing_units).to be > 5000
      expect(place.fips_class_code).to eq "C1"
      expect(place.land_area.round(1)).to eq 9.5
      expect(place.water_area.round(3)).to eq 0.009
      expect(place.lat.round).to eq 38
      expect(place.lng.round).to eq -122
    end
  end

end
