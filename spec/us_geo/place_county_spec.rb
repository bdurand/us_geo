# frozen_string_literal: true

require "spec_helper"

RSpec.describe USGeo::PlaceCounty do
  describe "associations" do
    it "should have a place" do
      place_county = USGeo::PlaceCounty.new
      place_county.place_geoid = "0000001"
      place_county.county_geoid = "00001"
      expect { place_county.place }.to_not raise_error
      expect(place_county.build_place).to be_a(USGeo::Place)
    end

    it "should have a county" do
      place_county = USGeo::PlaceCounty.new
      place_county.place_geoid = "0000001"
      place_county.county_geoid = "00001"
      expect { place_county.county }.to_not raise_error
      expect(place_county.build_county).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::PlaceCounty.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("place_counties.csv")

      USGeo::PlaceCounty.load!
      expect(USGeo::PlaceCounty.imported.count).to be > 30_000
      expect(USGeo::PlaceCounty.removed.count).to eq 0

      place_counties = USGeo::PlaceCounty.where(place_geoid: "3651000")
      expect(place_counties.size).to eq 5
      expect(place_counties.collect(&:county_geoid)).to match_array(["36005", "36047", "36061", "36081", "36085"])
    end
  end
end
