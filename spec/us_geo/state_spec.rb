require 'spec_helper'

describe USGeo::State do

  describe "associations" do
    it "should belong to a region" do
      state = USGeo::State.new
      state.code = "XX"
      expect{ state.region }.to_not raise_error
      expect(state.build_region).to be_a(USGeo::Region)
    end

    it "should belong to a division" do
      state = USGeo::State.new
      state.code = "XX"
      expect{ state.division }.to_not raise_error
      expect(state.build_division).to be_a(USGeo::Division)
    end

    it "should have counties" do
      state = USGeo::State.new
      state.code = "XX"
      expect{ state.counties }.to_not raise_error
      expect(state.counties.build).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::State.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/states.csv", __dir__))
      stub_request(:get, "#{USGeo::BaseRecord::BASE_DATA_URI}/states.csv").to_return(body: data)
      USGeo::State.load!
      expect(USGeo::State.count).to be > 1
      expect(USGeo::State.where(removed: true).count).to eq 0
 
      illinois = USGeo::State.find("IL")
      expect(illinois.name).to eq "Illinois"
      expect(illinois.type).to eq "state"
      expect(illinois.fips).to eq "17"
      expect(illinois.region_id).to eq 2
      expect(illinois.division_id).to eq 3
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
