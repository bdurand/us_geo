# frozen_string_literal: true

require "spec_helper"

describe USGeo::Region do
  describe "associations" do
    it "should have divisions" do
      region = USGeo::Region.new
      region.id = 1
      expect { region.divisions }.to_not raise_error
      expect(region.divisions.build).to be_a(USGeo::Division)
    end

    it "should have states" do
      region = USGeo::Region.new
      region.id = 1
      expect { region.states }.to_not raise_error
      expect(region.states.build).to be_a(USGeo::State)
    end
  end

  describe "load" do
    after { USGeo::Region.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("regions.csv")

      USGeo::Region.load!
      expect(USGeo::Region.imported.count).to eq 4
      expect(USGeo::Region.removed.count).to eq 0

      region = USGeo::Region.find(2)
      expect(region.name).to eq "Midwest"
      expect(region.population).to be_between(60_000_000, 80_000_000)
      expect(region.housing_units).to be_between(30_000_000, 40_000_000)
      expect(region.land_area.round).to be_between(700_000, 800_000)
      expect(region.water_area.round).to be_between(70_000, 80_000)
    end
  end
end
