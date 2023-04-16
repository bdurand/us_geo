require "spec_helper"

describe USGeo::ZctaPlace do
  describe "percentages" do
    it "should return the percentage of the population of the zcta" do
      zcta = USGeo::Zcta.new(population: 20_000)
      zcta_place = zcta.zcta_places.build(population: 5000)
      expect(zcta_place.percent_zcta_population).to eq 0.25
    end

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

    it "should return the percentage of the population of the zcta" do
      place = USGeo::Place.new(population: 20_000)
      zcta_place = place.zcta_places.build(population: 5000)
      expect(zcta_place.percent_place_population).to eq 0.25
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
      data = File.read(File.expand_path("../../data/dist/zcta_places.csv", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/zcta_places.csv").to_return(body: data, headers: {"Content-Type": "text/csv; charset=UTF-8"})
      USGeo::ZctaPlace.load!
      expect(USGeo::ZctaPlace.imported.count).to be > 45_000
      expect(USGeo::ZctaPlace.removed.count).to eq 0

      zcta_places = USGeo::ZctaPlace.where(zipcode: "53211")
      expect(zcta_places.size).to eq 3
      expect(zcta_places.collect(&:place_geoid)).to match_array(["5553000", "5573725", "5586700"])
      zcta_place = zcta_places.detect { |z| z.place_geoid == "5553000" }
      expect(zcta_place.population).to be > 15_000
      expect(zcta_place.housing_units).to be > 7000
      expect(zcta_place.land_area.round(1)).to eq 1.9
      expect(zcta_place.water_area.round(3)).to eq 0.055
    end
  end
end
