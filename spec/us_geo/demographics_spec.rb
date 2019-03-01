require "spec_helper"

describe USGeo::Demographics do

  let(:record) { USGeo::County.new(population: 90_000, land_area: 45.0, water_area: 5.0) }

  it "should return the population density of the land area" do
    expect(record.population_density).to eq 2000.0
  end

  it "should return the total area" do
    expect(record.total_area).to eq 50.0
  end

  it "should return the percent of land to water" do
    expect(record.percent_land).to eq 0.9
  end

end
