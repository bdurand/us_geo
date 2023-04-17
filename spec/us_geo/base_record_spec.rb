require "spec_helper"

describe USGeo::BaseRecord do
  describe "status" do
    it "should be marked as imported" do
      record = USGeo::County.new(status: 1)
      expect(record.imported?).to eq true
      expect(record.removed?).to eq false
      expect(record.manual?).to eq false
    end

    it "should be marked as removed" do
      record = USGeo::County.new(status: -1)
      expect(record.imported?).to eq false
      expect(record.removed?).to eq true
      expect(record.manual?).to eq false
    end

    it "should be marked as manual" do
      record = USGeo::County.new(status: 0)
      expect(record.imported?).to eq false
      expect(record.removed?).to eq false
      expect(record.manual?).to eq true
    end
  end

  describe "load!" do
    after { USGeo::Region.delete_all }

    it "should mark previously imported records as removed" do
      data = File.read(File.expand_path("../../data/2020_dist/regions.csv", __dir__))
      stub_request(:get, "#{USGeo.base_data_uri}/regions.csv").to_return(body: data, headers: {"Content-Type": "text/csv; charset=UTF-8"})

      midwest = USGeo::Region.new
      midwest.id = 2
      midwest.name = "Northwest Territory"
      midwest.status = USGeo::Region::STATUS_MANUAL
      midwest.save!

      other = USGeo::Region.new
      other.id = 90
      other.name = "Other"
      other.status = USGeo::Region::STATUS_IMPORTED
      other.save!

      manual = USGeo::Region.new
      manual.id = 80
      manual.name = "Manual"
      manual.status = USGeo::Region::STATUS_MANUAL
      manual.save!

      sleep(1)
      USGeo::Region.load!

      midwest.reload
      other.reload
      manual.reload

      expect(midwest.status).to eq USGeo::Region::STATUS_IMPORTED
      expect(midwest.name).to eq "Midwest"
      expect(other.status).to eq USGeo::Region::STATUS_REMOVED
      expect(manual.status).to eq USGeo::Region::STATUS_MANUAL
    end
  end
end
