require "spec_helper"

describe USGeo::UrbanArea do
  describe "associations" do
    it "should have zctas" do
      urban_area = USGeo::UrbanArea.new
      urban_area.geoid = "00001"
      expect { urban_area.zctas }.to_not raise_error
      expect { urban_area.zcta_urban_areas }.to_not raise_error
      expect(urban_area.zcta_urban_areas.build).to be_a(USGeo::ZctaUrbanArea)
    end

    it "should have counties" do
      urban_area = USGeo::UrbanArea.new
      urban_area.geoid = "00001"
      expect { urban_area.counties }.to_not raise_error
      expect { urban_area.urban_area_counties }.to_not raise_error
      expect(urban_area.urban_area_counties.build).to be_a(USGeo::UrbanAreaCounty)
    end

    it "should have a primary county" do
      urban_area = USGeo::UrbanArea.new
      urban_area.geoid = "00001"
      expect { urban_area.primary_county }.to_not raise_error
      expect(urban_area.build_primary_county).to be_a(USGeo::County)
    end

    it "should have county subdivisions" do
      urban_area = USGeo::UrbanArea.new
      urban_area.geoid = "00001"
      expect { urban_area.county_subdivisions }.to_not raise_error
      expect { urban_area.urban_area_county_subdivisions }.to_not raise_error
      expect(urban_area.urban_area_county_subdivisions.build).to be_a(USGeo::UrbanAreaCountySubdivision)
    end

    it "should have a core based statistical area via the primary county" do
      urban_area = USGeo::UrbanArea.new
      cbsa = USGeo::CoreBasedStatisticalArea.new
      county = USGeo::County.new
      county.core_based_statistical_area = cbsa
      urban_area.primary_county = county
      expect(urban_area.core_based_statistical_area).to eq cbsa
    end
  end

  describe "load" do
    after { USGeo::UrbanArea.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("urban_areas.csv")

      USGeo::UrbanArea.load!
      expect(USGeo::UrbanArea.imported.count).to be > 2300
      expect(USGeo::UrbanArea.removed.count).to eq 0

      chicago = USGeo::UrbanizedArea.find("16264")
      expect(chicago.name).to eq "Chicago, IL--IN Urban Area"
      expect(chicago.short_name).to eq "Chicago, IL"
      expect(chicago.primary_county_geoid).to eq "17031"
      expect(chicago.population).to be_between(8_000_000, 10_000_000)
      expect(chicago.housing_units).to be_between(3_000_000, 4_000_000)
      expect(chicago.land_area.round).to eq 2338
      expect(chicago.water_area.round).to eq 39
      expect(chicago.lat.round(1)).to eq 41.8
      expect(chicago.lng.round(1)).to eq(-87.9)
      expect(chicago.urbanized?).to eq true
      expect(chicago.cluster?).to eq false

      clinton = USGeo::UrbanCluster.find("17884")
      expect(clinton.name).to eq "Clinton, IL Urban Area"
      expect(clinton.short_name).to eq "Clinton, IL"
      expect(clinton.urbanized?).to eq false
      expect(clinton.cluster?).to eq true
    end
  end
end
