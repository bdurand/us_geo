# frozen_string_literal: true

require "spec_helper"

RSpec.describe USGeo::ZctaMapping do
  describe "associations" do
    it "should have a zcta" do
      zcta_mapping = USGeo::ZctaMapping.new
      zcta_mapping.zcta_zipcode = "60302"
      expect { zcta_mapping.zcta }.to_not raise_error
      expect(zcta_mapping.build_zcta).to be_a(USGeo::Zcta)
    end
  end

  describe "load" do
    after { USGeo::ZctaMapping.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("zcta_mappings.csv")

      USGeo::ZctaMapping.load!
      expect(USGeo::ZctaMapping.imported.count).to be > 200
      expect(USGeo::ZctaMapping.removed.count).to eq 0

      zcta_mapping = USGeo::ZctaMapping.find_by(zipcode: "56177")
      expect(zcta_mapping.zcta_zipcode).to eq("56144")
    end
  end
end
