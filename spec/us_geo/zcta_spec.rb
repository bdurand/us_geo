# frozen_string_literal: true

require "spec_helper"

RSpec.describe USGeo::Zcta do
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

    it "should have a primary county subdivision" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect { zcta.primary_county_subdivision }.to_not raise_error
      expect(zcta.build_primary_county_subdivision).to be_a(USGeo::CountySubdivision)
    end

    it "should have county subdivisions" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect { zcta.county_subdivisions }.to_not raise_error
      expect { zcta.zcta_county_subdivisions }.to_not raise_error
      expect(zcta.zcta_county_subdivisions.build).to be_a(USGeo::ZctaCountySubdivision)
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

    it "should have a primary urban area" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect { zcta.primary_urban_area }.to_not raise_error
      expect(zcta.build_primary_urban_area).to be_a(USGeo::UrbanArea)
    end

    it "should have urban areas" do
      zcta = USGeo::Zcta.new
      zcta.zipcode = "60304"
      expect { zcta.urban_areas }.to_not raise_error
      expect { zcta.zcta_urban_areas }.to_not raise_error
      expect(zcta.zcta_urban_areas.build).to be_a(USGeo::ZctaUrbanArea)
    end
  end

  describe "validations" do
    let(:zcta) do
      USGeo::Zcta.new(
        zipcode: "53211",
        primary_county_geoid: "55079",
        land_area: 4.5,
        water_area: 0.2,
        lat: 43.1,
        lng: -87.9,
        population: 17000,
        housing_units: 8000
      )
    end

    it "should allow a blank USPS locality and state code" do
      zcta.usps_locality = nil
      zcta.usps_state_code = nil
      expect(zcta).to be_valid
    end

    it "should not allow a USPS locality longer than 30 characters" do
      zcta.usps_locality = "M" * 30
      expect(zcta).to be_valid

      zcta.usps_locality = "M" * 31
      expect(zcta).to_not be_valid
      expect(zcta.errors[:usps_locality]).to_not be_empty
    end

    it "should only allow a two character USPS state code" do
      zcta.usps_state_code = "WI"
      expect(zcta).to be_valid

      zcta.usps_state_code = "WIS"
      expect(zcta).to_not be_valid
      expect(zcta.errors[:usps_state_code]).to_not be_empty
    end
  end

  describe "for_zipcode" do
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
      expect(zcta.primary_county_subdivision_geoid).to eq "5507953000"
      expect(zcta.primary_place_geoid).to eq "5553000"
      expect(zcta.primary_urban_area_geoid).to eq "57466"
      expect(zcta.usps_locality).to eq "MILWAUKEE"
      expect(zcta.usps_state_code).to eq "WI"
      expect(zcta.population).to be_between(30_000, 40_000)
      expect(zcta.housing_units).to be_between(15_000, 20_000)
      expect(zcta.land_area.round(2)).to eq 3.97
      expect(zcta.water_area.round(2)).to eq 0.64
      expect(zcta.lat.round(1)).to eq 43.1
      expect(zcta.lng.round(1)).to eq(-87.9)
    end

    it "should load the USPS locality of the post office serving the ZIP code" do
      mock_data_file_request("zctas.csv")

      USGeo::Zcta.load!

      # The locality is the city the post office is in rather than the name of the
      # post office itself (i.e. not "BEVERLY HILLS CARRIER ANNEX").
      expect(USGeo::Zcta.find("90210").usps_locality).to eq "BEVERLY HILLS"
      expect(USGeo::Zcta.find("60304").usps_locality).to eq "OAK PARK"
      expect(USGeo::Zcta.find("10001").usps_locality).to eq "NEW YORK"
    end

    it "should load a USPS state code that differs from the primary county's state" do
      mock_data_file_request("zctas.csv")

      USGeo::Zcta.load!

      # 21875 is in a Maryland county, but is served by the Laurel, Delaware post office.
      zcta = USGeo::Zcta.find("21875")
      expect(zcta.primary_county_geoid).to start_with "24"
      expect(zcta.usps_locality).to eq "LAUREL"
      expect(zcta.usps_state_code).to eq "DE"
    end

    it "should leave the USPS locality blank for ZIP codes the postal service does not deliver to" do
      mock_data_file_request("zctas.csv")

      USGeo::Zcta.load!

      zcta = USGeo::Zcta.find("01003")
      expect(zcta.usps_locality).to be_nil
      expect(zcta.usps_state_code).to be_nil
    end
  end
end
