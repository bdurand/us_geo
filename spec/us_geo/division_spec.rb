# frozen_string_literal: true

require "spec_helper"

RSpec.describe USGeo::Division do
  describe "associations" do
    it "should have a region" do
      division = USGeo::Division.new
      division.id = 1
      expect { division.region }.to_not raise_error
      expect(division.build_region).to be_a(USGeo::Region)
    end

    it "should have states" do
      division = USGeo::Division.new
      division.id = 1
      expect { division.states }.to_not raise_error
      expect(division.states.build).to be_a(USGeo::State)
    end
  end

  describe "load" do
    after { USGeo::Division.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("divisions.csv")

      USGeo::Division.load!
      expect(USGeo::Division.imported.count).to eq 9
      expect(USGeo::Division.removed.count).to eq 0

      division = USGeo::Division.find(2)
      expect(division.name).to eq "Middle Atlantic"
      expect(division.region_id).to eq 1
      expect(division.population).to be_between(30_000_000, 50_000_000)
      expect(division.housing_units).to be_between(10_000_000, 30_000_000)
      expect(division.land_area).to be_between(90_000, 100_000)
      expect(division.water_area.round).to be_between(9000, 11000)
    end
  end
end
