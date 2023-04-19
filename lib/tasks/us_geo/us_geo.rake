# frozen_string_literal: true

namespace :us_geo do
  namespace :import do
    klasses = {
      regions: USGeo::Region,
      divisions: USGeo::Division,
      states: USGeo::State,
      designated_market_areas: USGeo::DesignatedMarketArea,
      combined_statistical_areas: USGeo::CombinedStatisticalArea,
      core_based_statistical_areas: USGeo::CoreBasedStatisticalArea,
      metropolitan_divisions: USGeo::MetropolitanDivision,
      counties: USGeo::County,
      county_subdivisions: USGeo::CountySubdivision,
      places: USGeo::Place,
      zctas: USGeo::Zcta,
      zcta_counties: USGeo::ZctaCounty,
      zcta_county_subdivisions: USGeo::ZctaCountySubdivision,
      zcta_places: USGeo::ZctaPlace,
      place_counties: USGeo::PlaceCounty
    }

    klasses.each do |name, klass|
      desc "Import data for #{klass}"
      task name => :environment do
        t = Time.now
        klass.load!
        puts "Loaded #{klass.count} rows into #{klass.table_name} in #{(Time.now - t).round(1)}s"
        klass.removed.find_each do |record|
          puts("  WARNING: #{klass}.#{record.id} status changed to removed")
        end
      end

      desc "Import data for all USGeo models"
      task all: :environment do
        klasses.each_key do |name|
          Rake::Task["us_geo:import:#{name}"].invoke
        end
      end
    end

    desc "Remove all records from previously imported data that no longer exists in the current data source"
    task cleanup: :environment do
      klasses.each_value do |klass|
        count = 0
        klass.removed.find_each do |record|
          count += 1
          record.destroy
        end
        puts "Deleted #{count} removed records from #{klass.table_name}"
      end
    end
  end
end
