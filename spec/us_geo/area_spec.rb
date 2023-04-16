require "spec_helper"

describe USGeo::Area do
  let(:record) { USGeo::County.new(land_area: 45.0, water_area: 5.0) }
  let(:nil_record) { USGeo::County.new }

  it "should return the total area" do
    expect(record.total_area).to eq 50.0
    expect(nil_record.total_area).to eq nil
  end

  it "should return the percent of land to water" do
    expect(record.percent_land).to eq 0.9
    expect(nil_record.percent_land).to eq nil
  end

  it "should convert the land area from miles to kilometers" do
    expect(record.land_area_km.round(3)).to eq 72.42
    expect(nil_record.land_area_km).to eq nil
  end

  it "should convert the water area from miles to kilometers" do
    expect(record.water_area_km.round(3)).to eq 8.047
    expect(nil_record.water_area_km).to eq nil
  end
end
