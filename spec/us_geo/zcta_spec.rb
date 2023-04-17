# frozen_string_literal: true

require "spec_helper"

describe USGeo::Zcta do
  describe "associations" do
    it "should have a primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect { zcta.primary_county }.to_not raise_error
      expect(zcta.build_primary_county).to be_a(USGeo::County)
    end

    it "should have counties" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect { zcta.counties }.to_not raise_error
      expect { zcta.zcta_counties }.to_not raise_error
      expect(zcta.zcta_counties.build).to be_a(USGeo::ZctaCounty)
    end

    it "should have a time zone via the primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      county = USGeo::County.new(time_zone_name: "America/Chicago")
      zcta.primary_county = county
      expect(zcta.time_zone).to eq ActiveSupport::TimeZone["America/Chicago"]
    end

    it "should have a state via the primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      state = USGeo::State.new
      state.code = "XX"
      county = USGeo::County.new(state_code: "XX")
      county.state = state
      zcta.primary_county = county
      expect(zcta.state_code).to eq "XX"
      expect(zcta.state).to eq state
    end

    it "should have a core based statistical area via the primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      cbsa = USGeo::CoreBasedStatisticalArea.new
      county = USGeo::County.new
      county.core_based_statistical_area = cbsa
      zcta.primary_county = county
      expect(zcta.core_based_statistical_area).to eq cbsa
    end

    it "should have a designated market area via the primary county" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      dma = USGeo::DesignatedMarketArea.new
      county = USGeo::County.new
      county.designated_market_area = dma
      zcta.primary_county = county
      expect(zcta.designated_market_area).to eq dma
    end

    it "should have a primary place" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect { zcta.primary_place }.to_not raise_error
      expect(zcta.build_primary_place).to be_a(USGeo::Place)
    end

    it "should have places" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect { zcta.places }.to_not raise_error
      expect { zcta.zcta_places }.to_not raise_error
      expect(zcta.zcta_places.build).to be_a(USGeo::ZctaPlace)
    end
  end

  describe "for_zipecode" do
    after { USGeo::Zcta.delete_all }

    it "should return a zcta with an active ZIP code" do
      USGeo::Zcta.create!(
        zipcode: "53211",
        primary_county_geoid: "55079",
        land_area: 4.5,
        water_area: 0.2,
        lat: 43.1,
        lng: -87.9,
        population: 17000,
        housing_units: 8000
      )
      USGeo::Zcta.create!(
        zipcode: "60304",
        primary_county_geoid: "17031",
        land_area: 4.5,
        water_area: 0.2,
        lat: 43.1,
        lng: -87.9,
        population: 17000,
        housing_units: 8000
      )

      expect(USGeo::Zcta.for_zipcode("53211").collect(&:zipcode)).to eq ["53211"]
      expect(USGeo::Zcta.for_zipcode("60304").collect(&:zipcode)).to eq ["60304"]
    end

    it "should return a zcta mapped from an inactive ZIP code" do
      USGeo::Zcta.create!(
        zipcode: "53211",
        primary_county_geoid: "55079",
        land_area: 4.5,
        water_area: 0.2,
        lat: 43.1,
        lng: -87.9,
        population: 17000,
        housing_units: 8000
      )
      USGeo::Zcta.create!(
        zipcode: "60304",
        primary_county_geoid: "17031",
        land_area: 4.5,
        water_area: 0.2,
        lat: 43.1,
        lng: -87.9,
        population: 17000,
        housing_units: 8000
      )
      USGeo::ZctaMapping.create!(zipcode: "53211", zcta_zipcode: "53211")
      USGeo::ZctaMapping.create!(zipcode: "60301", zcta_zipcode: "60304")

      expect(USGeo::Zcta.for_zipcode("53211").collect(&:zipcode)).to eq ["53211"]
      expect(USGeo::Zcta.for_zipcode("60304").collect(&:zipcode)).to eq ["60304"]
      expect(USGeo::Zcta.for_zipcode("60301").collect(&:zipcode)).to eq ["60304"]
    end
  end

  describe "load" do
    after { USGeo::Zcta.delete_all }

    it "should load the fixture data" do
      mock_data_file_request("zctas.csv")

      USGeo::Zcta.load!
      expect(USGeo::Zcta.imported.count).to be > 30_000
      expect(USGeo::Zcta.removed.count).to eq 0

      zcta = USGeo::Zcta.find("53211")
      expect(zcta.primary_county_geoid).to eq "55079"
      expect(zcta.primary_place_geoid).to eq "5553000"
      expect(zcta.population).to be_between(30_000, 40_000)
      expect(zcta.housing_units).to be_between(15_000, 20_000)
      expect(zcta.land_area.round(2)).to eq 3.97
      expect(zcta.water_area.round(2)).to eq 0.64
      expect(zcta.lat.round(1)).to eq 43.1
      expect(zcta.lng.round(1)).to eq(-87.9)
    end
  end
end
