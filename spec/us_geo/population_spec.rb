# frozen_string_literal: true

require "spec_helper"

describe USGeo::Area do
  let(:record) { USGeo::County.new(population: 90_000, housing_units: 18_000, land_area: 45.0, water_area: 10.0) }
  let(:nil_record) { USGeo::County.new }

  it "should return the population density of the land area" do
    expect(record.population_density).to eq 2000.0
    expect(record.population_density_km.round(1)).to eq 772.2
    expect(nil_record.population_density).to eq nil
  end

  it "should return the housing density of the land area" do
    expect(record.housing_density).to eq 400.0
    expect(record.housing_density_km.round(1)).to eq 154.4
    expect(nil_record.population_density).to eq nil
  end
end
