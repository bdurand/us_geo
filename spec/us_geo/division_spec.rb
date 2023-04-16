require "spec_helper"

describe USGeo::Division do
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
      data = File.read(File.expand_path("../../data/dist/divisions.csv", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/divisions.csv").to_return(body: data, headers: {"Content-Type": "text/csv; charset=UTF-8"})
      USGeo::Division.load!
      expect(USGeo::Division.imported.count).to eq 9
      expect(USGeo::Division.removed.count).to eq 0

      division = USGeo::Division.find(2)
      expect(division.name).to eq "Middle Atlantic"
      expect(division.region_id).to eq 1
    end
  end
end
