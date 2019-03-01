require 'spec_helper'

describe USGeo::Region do

  describe "associations" do
    it "should have divisions" do
      region = USGeo::Region.new
      region.id = 1
      expect{ region.divisions }.to_not raise_error
      expect(region.divisions.build).to be_a(USGeo::Division)
    end

    it "should have states" do
      region = USGeo::Region.new
      region.id = 1
      expect{ region.states }.to_not raise_error
      expect(region.states.build).to be_a(USGeo::State)
    end
  end

  describe "load" do
    after { USGeo::Region.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/divisions.csv", __dir__))
      stub_request(:get, "#{USGeo::BaseRecord::BASE_DATA_URI}/divisions.csv").to_return(body: data)
      USGeo::Region.load!
      expect(USGeo::Region.count).to be > 1
      expect(USGeo::Region.where(removed: true).count).to eq 0
 
      region = USGeo::Region.find(2)
      expect(region.name).to eq "Midwest"
    end
  end

end
