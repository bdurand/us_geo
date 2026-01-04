# frozen_string_literal: true

require "spec_helper"

RSpec.describe USGeo::State do
  describe "associations" do
    it "should belong to a region" do
      state = USGeo::State.new
      state.code = "XX"
      expect { state.region }.to_not raise_error
      expect(state.build_region).to be_a(USGeo::Region)
    end

    it "should belong to a division" do
      state = USGeo::State.new
      state.code = "XX"
      expect { state.division }.to_not raise_error
      expect(state.build_division).to be_a(USGeo::Division)
    end

    it "should have counties" do
      state = USGeo::State.new
      state.code = "XX"
      expect { state.counties }.to_not raise_error
      expect(state.counties.build).to be_a(USGeo::County)
    end

    it "should have places" do
      state = USGeo::State.new
      state.code = "XX"
      expect { state.places }.to_not raise_error
      expect(state.places.build).to be_a(USGeo::Place)
    end
  end

  describe "load" do
    after { USGeo::State.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("states.csv")

      USGeo::State.load!
      expect(USGeo::State.imported.count).to eq 56
      expect(USGeo::State.removed.count).to eq 0

      illinois = USGeo::State.find("IL")
      expect(illinois.name).to eq "Illinois"
      expect(illinois.type).to eq "state"
      expect(illinois.fips).to eq "17"
      expect(illinois.region_id).to eq 2
      expect(illinois.division_id).to eq 3
      expect(illinois.population).to be_between(10_000_000, 15_000_000)
      expect(illinois.housing_units).to be_between(5_000_000, 7_000_000)
      expect(illinois.land_area.round).to be_between(50_000, 60_000)
      expect(illinois.water_area.round).to be_between(2000, 3000)
    end
  end

  describe "type" do
    it "should detect the state type" do
      expect(USGeo::State.new(type: "state").state?).to eq true
      expect(USGeo::State.new(type: "territory").state?).to eq false
      expect(USGeo::State.new(type: "district").state?).to eq false

      expect(USGeo::State.new(type: "state").district?).to eq false
      expect(USGeo::State.new(type: "territory").district?).to eq false
      expect(USGeo::State.new(type: "district").district?).to eq true

      expect(USGeo::State.new(type: "state").territory?).to eq false
      expect(USGeo::State.new(type: "territory").territory?).to eq true
      expect(USGeo::State.new(type: "district").territory?).to eq false
    end
  end
end
