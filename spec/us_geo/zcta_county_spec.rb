require "spec_helper"

describe USGeo::ZctaCounty do
  describe "percentages" do
    it "should return the percentage of the land area of the zcta" do
      zcta = USGeo::Zcta.new(land_area: 200)
      zcta_county = zcta.zcta_counties.build(land_area: 50)
      expect(zcta_county.percent_zcta_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the zcta" do
      zcta = USGeo::Zcta.new(land_area: 150, water_area: 50)
      zcta_county = zcta.zcta_counties.build(land_area: 30, water_area: 20)
      expect(zcta_county.percent_zcta_total_area).to eq 0.25
    end

    it "should return the percentage of the land area of the county" do
      county = USGeo::County.new(land_area: 200)
      zcta_county = county.zcta_counties.build(land_area: 50)
      expect(zcta_county.percent_county_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the county" do
      county = USGeo::County.new(land_area: 150, water_area: 50)
      zcta_county = county.zcta_counties.build(land_area: 30, water_area: 20)
      expect(zcta_county.percent_county_total_area).to eq 0.25
    end
  end

  describe "associations" do
    it "should have a zcta" do
      zcta_county = USGeo::ZctaCounty.new
      zcta_county.zipcode = "60304"
      zcta_county.county_geoid = "00001"
      expect { zcta_county.zcta }.to_not raise_error
      expect(zcta_county.build_zcta).to be_a(USGeo::Zcta)
    end

    it "should have a county" do
      zcta_county = USGeo::ZctaCounty.new
      zcta_county.zipcode = "60304"
      zcta_county.county_geoid = "00001"
      expect { zcta_county.county }.to_not raise_error
      expect(zcta_county.build_county).to be_a(USGeo::County)
    end
  end

  describe "load" do
    after { USGeo::ZctaCounty.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("zcta_counties.csv")

      USGeo::ZctaCounty.load!
      expect(USGeo::ZctaCounty.imported.count).to be > 40_000
      expect(USGeo::ZctaCounty.removed.count).to eq 0

      zcta_counties = USGeo::ZctaCounty.where(zipcode: "00601")
      expect(zcta_counties.size).to eq 2
      expect(zcta_counties.collect(&:county_geoid)).to match_array(["72001", "72141"])
      zcta_county = zcta_counties.detect { |z| z.county_geoid == "72001" }
      expect(zcta_county.land_area.round(1)).to eq 63.6
      expect(zcta_county.water_area.round(1)).to eq 0.3
    end
  end
end
