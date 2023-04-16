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
      mock_data_file_request("divisions.csv")
      USGeo::Region.load!
      expect(USGeo::Region.imported.count).to eq 4
      expect(USGeo::Region.removed.count).to eq 0

      region = USGeo::Region.find(2)
      expect(region.name).to eq "Midwest"
    end
  end
end
