require "spec_helper"

describe USGeo::ZctaPlace do
  describe "percentages" do
    it "should return the percentage of the land area of the zcta" do
      zcta = USGeo::Zcta.new(land_area: 200)
      zcta_place = zcta.zcta_places.build(land_area: 50)
      expect(zcta_place.percent_zcta_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the zcta" do
      zcta = USGeo::Zcta.new(land_area: 150, water_area: 50)
      zcta_place = zcta.zcta_places.build(land_area: 30, water_area: 20)
      expect(zcta_place.percent_zcta_total_area).to eq 0.25
    end

    it "should return the percentage of the land area of the zcta" do
      place = USGeo::Place.new(land_area: 200)
      zcta_place = place.zcta_places.build(land_area: 50)
      expect(zcta_place.percent_place_land_area).to eq 0.25
    end

    it "should return the percentage of the total area of the zcta" do
      place = USGeo::Place.new(land_area: 150, water_area: 50)
      zcta_place = place.zcta_places.build(land_area: 30, water_area: 20)
      expect(zcta_place.percent_place_total_area).to eq 0.25
    end
  end

  describe "associations" do
    it "should have a zcta" do
      zcta_place = USGeo::ZctaPlace.new
      zcta_place.zipcode = "60304"
      zcta_place.place_geoid = "0000001"
      expect { zcta_place.zcta }.to_not raise_error
      expect(zcta_place.build_zcta).to be_a(USGeo::Zcta)
    end

    it "should have a place" do
      zcta_place = USGeo::ZctaPlace.new
      zcta_place.zipcode = "60304"
      zcta_place.place_geoid = "0000001"
      expect { zcta_place.place }.to_not raise_error
      expect(zcta_place.build_place).to be_a(USGeo::Place)
    end
  end

  describe "load" do
    after { USGeo::ZctaPlace.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("zcta_places.csv")

      USGeo::ZctaPlace.load!
      expect(USGeo::ZctaPlace.imported.count).to be > 45_000
      expect(USGeo::ZctaPlace.removed.count).to eq 0

      zcta_places = USGeo::ZctaPlace.where(zipcode: "53211")
      expect(zcta_places.size).to eq 3
      expect(zcta_places.collect(&:place_geoid)).to match_array(["5553000", "5573725", "5586700"])
      zcta_place = zcta_places.detect { |z| z.place_geoid == "5553000" }
      expect(zcta_place.land_area.round(2)).to eq 1.97
      expect(zcta_place.water_area.round(3)).to eq 0.09
    end
  end
end
