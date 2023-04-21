require "spec_helper"

describe USGeo::UrbanAreaCountySubdivision do
  describe "percentages" do
    it "should return the percentage of the land area of the urban area" do
      urban_area = USGeo::UrbanArea.new(land_area: 200)
      urban_area_county_subdivision = urban_area.urban_area_county_subdivisions.build(land_area: 50)
      expect(urban_area_county_subdivision.percent_urban_area_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the urban area" do
      urban_area = USGeo::UrbanArea.new(land_area: 150, water_area: 50)
      urban_area_county_subdivision = urban_area.urban_area_county_subdivisions.build(land_area: 30, water_area: 20)
      expect(urban_area_county_subdivision.percent_urban_area_total_area).to eq 0.25
    end

    it "should return the percentage of the land area of the county_subdivision" do
      county_subdivision = USGeo::CountySubdivision.new(land_area: 200)
      urban_area_county_subdivision = county_subdivision.urban_area_county_subdivisions.build(land_area: 50)
      expect(urban_area_county_subdivision.percent_county_subdivision_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the county_subdivision" do
      county_subdivision = USGeo::CountySubdivision.new(land_area: 150, water_area: 50)
      urban_area_county_subdivision = county_subdivision.urban_area_county_subdivisions.build(land_area: 30, water_area: 20)
      expect(urban_area_county_subdivision.percent_county_subdivision_total_area).to eq 0.25
    end
  end

  describe "associations" do
    it "should have a county_subdivision" do
      urban_area_county_subdivision = USGeo::UrbanAreaCountySubdivision.new
      urban_area_county_subdivision.county_subdivision_geoid = "60304"
      urban_area_county_subdivision.urban_area_geoid = "00001"
      expect { urban_area_county_subdivision.county_subdivision }.to_not raise_error
      expect(urban_area_county_subdivision.build_county_subdivision).to be_a(USGeo::CountySubdivision)
    end

    it "should have an urban area" do
      urban_area_county_subdivision = USGeo::UrbanAreaCountySubdivision.new
      urban_area_county_subdivision.county_subdivision_geoid = "60304"
      urban_area_county_subdivision.urban_area_geoid = "00001"
      expect { urban_area_county_subdivision.urban_area }.to_not raise_error
      expect(urban_area_county_subdivision.build_urban_area).to be_a(USGeo::UrbanArea)
    end
  end

  describe "load" do
    after { USGeo::UrbanAreaCountySubdivision.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("urban_area_county_subdivisions.csv")

      USGeo::UrbanAreaCountySubdivision.load!
      expect(USGeo::UrbanAreaCountySubdivision.imported.count).to be > 4000
      expect(USGeo::UrbanAreaCountySubdivision.removed.count).to eq 0

      urban_area_county_subdivisions = USGeo::UrbanAreaCountySubdivision.where(urban_area_geoid: "39430")
      expect(urban_area_county_subdivisions.size).to eq 10
      expect(urban_area_county_subdivisions.collect(&:county_subdivision_geoid)).to match_array(["2600528120", "2600538640", "2600545180", "2613938640", "2613938660", "2613960460", "2613962460", "2613965940", "2613989260", "2613989280"])
      urban_area_county_subdivision = urban_area_county_subdivisions.detect { |z| z.county_subdivision_geoid == "2600538640" }
      expect(urban_area_county_subdivision.land_area.round(1)).to eq 7.7
      expect(urban_area_county_subdivision.water_area.round(2)).to eq 0.07
    end
  end
end
