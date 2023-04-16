require "spec_helper"

describe USGeo::CountySubdivision do
  describe "associations" do
    it "should have a county" do
      subdivision = USGeo::CountySubdivision.new
      subdivision.geoid = "0000000001"
      expect { subdivision.county }.to_not raise_error
      expect(subdivision.build_county).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::CountySubdivision.delete_all }

    it "should load the fixture data" do
      data = File.read(File.expand_path("../../data/dist/county_subdivisions.csv", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/county_subdivisions.csv").to_return(body: data, headers: {"Content-Type": "text/csv; charset=UTF-8"})
      USGeo::CountySubdivision.load!
      expect(USGeo::CountySubdivision.imported.count).to be > 35_000
      expect(USGeo::CountySubdivision.removed.count).to eq 0

      subdivision = USGeo::CountySubdivision.find("2600545180")
      expect(subdivision.name).to eq "Township of Laketown"
      expect(subdivision.county_geoid).to eq "26005"
      expect(subdivision.population).to be > 5000
      expect(subdivision.housing_units).to be > 2000
      expect(subdivision.fips_class_code).to eq "T1"
      expect(subdivision.land_area.round).to eq 22
      expect(subdivision.water_area.round(1)).to eq 0.1
      expect(subdivision.lat.round).to eq 43
      expect(subdivision.lng.round).to eq(-86)
    end
  end
end
