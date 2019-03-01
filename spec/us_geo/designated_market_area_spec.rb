require 'spec_helper'

describe USGeo::DesignatedMarketArea do

  describe "associations" do
    it "should have counties" do
      division = USGeo::DesignatedMarketArea.new
      division.id = 1
      expect{ division.counties }.to_not raise_error
      expect(division.counties.build).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::DesignatedMarketArea.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/dmas.csv", __dir__))
      stub_request(:get, "#{USGeo::BaseRecord::BASE_DATA_URI}/dmas.csv").to_return(body: data)
      USGeo::DesignatedMarketArea.load!
      expect(USGeo::DesignatedMarketArea.count).to be > 1
      expect(USGeo::DesignatedMarketArea.where(removed: true).count).to eq 0

      dma = USGeo::DesignatedMarketArea.find("602")
      expect(dma.name).to eq "Chicago, IL"
    end
  end

end
