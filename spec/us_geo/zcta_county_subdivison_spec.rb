# frozen_string_literal: true

require "spec_helper"

RSpec.describe USGeo::ZctaCountySubdivision do
  describe "percentages" do
    it "should return the percentage of the land area of the zcta" do
      zcta = USGeo::Zcta.new(land_area: 200)
      zcta_county_subdivision = zcta.zcta_county_subdivisions.build(land_area: 50)
      expect(zcta_county_subdivision.percent_zcta_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the zcta" do
      zcta = USGeo::Zcta.new(land_area: 150, water_area: 50)
      zcta_county_subdivision = zcta.zcta_county_subdivisions.build(land_area: 30, water_area: 20)
      expect(zcta_county_subdivision.percent_zcta_total_area).to eq 0.25
    end

    it "should return the percentage of the land area of the county" do
      subdivision = USGeo::CountySubdivision.new(land_area: 200)
      zcta_county_subdivision = subdivision.zcta_county_subdivisions.build(land_area: 50)
      expect(zcta_county_subdivision.percent_county_subdivision_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the county" do
      subdivision = USGeo::CountySubdivision.new(land_area: 150, water_area: 50)
      zcta_county_subdivision = subdivision.zcta_county_subdivisions.build(land_area: 30, water_area: 20)
      expect(zcta_county_subdivision.percent_county_subdivision_total_area).to eq 0.25
    end
  end

  describe "associations" do
    it "should have a zcta" do
      zcta_county_subdivision = USGeo::ZctaCountySubdivision.new
      zcta_county_subdivision.zipcode = "60304"
      zcta_county_subdivision.county_subdivision_geoid = "00001"
      expect { zcta_county_subdivision.zcta }.to_not raise_error
      expect(zcta_county_subdivision.build_zcta).to be_a(USGeo::Zcta)
    end

    it "should have a county" do
      zcta_county_subdivision = USGeo::ZctaCountySubdivision.new
      zcta_county_subdivision.zipcode = "60304"
      zcta_county_subdivision.county_subdivision_geoid = "00001"
      expect { zcta_county_subdivision.county_subdivision }.to_not raise_error
      expect(zcta_county_subdivision.build_county_subdivision).to be_a(USGeo::CountySubdivision)
    end
  end

  describe "load" do
    after { USGeo::ZctaCountySubdivision.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("zcta_county_subdivisions.csv")

      USGeo::ZctaCountySubdivision.load!
      expect(USGeo::ZctaCountySubdivision.imported.count).to be > 100_000
      expect(USGeo::ZctaCountySubdivision.removed.count).to eq 0

      zcta_county_subdivisions = USGeo::ZctaCountySubdivision.where(zipcode: "00601")
      expect(zcta_county_subdivisions.collect(&:county_subdivision_geoid)).to match_array([
        "7200100401",
        "7200113645",
        "7200130458",
        "7200132049",
        "7200132608",
        "7200132780",
        "7200139273",
        "7200145422",
        "7200160773",
        "7200163955",
        "7200163998",
        "7200174963",
        "7200181714",
        "7200185584",
        "7200185627",
        "7200187949",
        "7200188250",
        "7214120095"
      ])
      zcta_county_subdivision = zcta_county_subdivisions.detect { |z| z.county_subdivision_geoid == "7200160773" }
      expect(zcta_county_subdivision.land_area.round(3)).to eq 3.484
      expect(zcta_county_subdivision.water_area.round(3)).to eq 0.007
    end
  end
end
