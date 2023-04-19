# frozen_string_literal: true

require "spec_helper"

describe USGeo::Place do
  describe "associations" do
    it "should have a state" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect { place.state }.to_not raise_error
      expect(place.build_state).to be_a(USGeo::State)
    end

    it "should have a primary county" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect { place.primary_county }.to_not raise_error
      expect(place.build_primary_county).to be_a(USGeo::County)
    end

    it "should have counties" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect { place.counties }.to_not raise_error
      expect { place.place_counties }.to_not raise_error
      expect(place.place_counties.build).to be_a(USGeo::PlaceCounty)
    end

    it "should have zctas" do
      place = USGeo::Place.new
      place.geoid = "0000001"
      expect { place.zctas }.to_not raise_error
      expect { place.zcta_places }.to_not raise_error
      expect(place.zcta_places.build).to be_a(USGeo::ZctaPlace)
    end
  end

  describe "full_name" do
    it "should return the full name" do
      place = USGeo::Place.new(short_name: "Chicago", state_code: "IL")
      expect(place.full_name).to eq "Chicago, IL"
    end
  end

  describe "load" do
    after { USGeo::Place.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("places.csv")

      USGeo::Place.load!
      expect(USGeo::Place.imported.count).to be > 30_000
      expect(USGeo::Place.removed.count).to eq 0

      place = USGeo::Place.find("0649187")
      expect(place.gnis_id).to eq 2413013
      expect(place.name).to eq "Town of Moraga"
      expect(place.short_name).to eq "Moraga"
      expect(place.state_code).to eq "CA"
      expect(place.primary_county_geoid).to eq "06013"
      expect(place.population).to be_between(15_000, 20_000)
      expect(place.housing_units).to be_between(5000, 7000)
      expect(place.fips_class_code).to eq "C1"
      expect(place.land_area.round(1)).to eq 9.5
      expect(place.water_area.round(3)).to eq 0.009
      expect(place.lat.round(1)).to eq 37.8
      expect(place.lng.round(1)).to eq(-122.1)
    end
  end
end
