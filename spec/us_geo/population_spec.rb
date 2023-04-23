# frozen_string_literal: true

require "spec_helper"

describe USGeo::Area do
  let(:record) { USGeo::County.new(population: 90_000, land_area: 45.0) }
  let(:nil_record) { USGeo::County.new }

  it "should return the population density of the land area" do
    expect(record.population_density).to eq 2000.0
    expect(nil_record.population_density).to eq nil
  end
end
