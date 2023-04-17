# frozen_string_literal: true

require "spec_helper"

describe USGeo::CountySubdivision do
  describe "associations" do
    it "should have a county" do
      subdivision = USGeo::CountySubdivision.new
      subdivision.geoid = "0000000001"
      expect { subdivision.county }.to_not raise_error
      expect(subdivision.build_county).to be_a(USGeo::County)
    end

    it "should have zctas" do
      subdivision = USGeo::CountySubdivision.new
      subdivision.geoid = "0000000001"
      expect { subdivision.zctas }.to_not raise_error
      expect { subdivision.zcta_county_subdivisions }.to_not raise_error
      expect(subdivision.zcta_county_subdivisions.build).to be_a(USGeo::ZctaCountySubdivision)
    end
  end

  describe "load" do
    after { USGeo::CountySubdivision.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("county_subdivisions.csv")

      USGeo::CountySubdivision.load!
      expect(USGeo::CountySubdivision.imported.count).to be > 35_000
      expect(USGeo::CountySubdivision.removed.count).to eq 0

      subdivision = USGeo::CountySubdivision.find("2600545180")
      expect(subdivision.name).to eq "Township of Laketown"
      expect(subdivision.county_geoid).to eq "26005"
      expect(subdivision.population).to be_between(5000, 6000)
      expect(subdivision.housing_units).to be_between(2000, 3000)
      expect(subdivision.fips_class_code).to eq "T1"
      expect(subdivision.land_area.round).to eq 22
      expect(subdivision.water_area.round(1)).to eq 0.1
      expect(subdivision.lat.round(1)).to eq 42.7
      expect(subdivision.lng.round(1)).to eq(-86.2)
    end
  end
end
