# frozen_string_literal: true

namespace :us_geo do
  namespace :import do
    klasses = {
      regions: USGeo::Region,
      divisions: USGeo::Division,
      states: USGeo::State,
      combined_statistical_areas: USGeo::CombinedStatisticalArea,
      core_based_statistical_areas: USGeo::CoreBasedStatisticalArea,
      metropolitan_divisions: USGeo::MetropolitanDivision,
      counties: USGeo::County,
      county_subdivisions: USGeo::CountySubdivision,
      urban_areas: USGeo::UrbanArea,
      places: USGeo::Place,
      zctas: USGeo::Zcta,
      zcta_counties: USGeo::ZctaCounty,
      zcta_urban_areas: USGeo::ZctaUrbanArea,
      zcta_county_subdivisions: USGeo::ZctaCountySubdivision,
      zcta_places: USGeo::ZctaPlace,
      urban_area_counties: USGeo::UrbanAreaCounty,
      urban_area_county_subdivisions: USGeo::UrbanAreaCountySubdivision,
      place_counties: USGeo::PlaceCounty
    }

    klasses.each do |name, klass|
      desc "Import data for #{klass}"
      task name => :environment do
        t = Time.now

        klass.load!
        puts "Loaded #{klass.count} rows into #{klass.table_name} in #{(Time.now - t).round(1)}s"

        removed_count = klass.removed.count
        if removed_count > 0
          puts "  #{removed_count} previously imported records in #{klass.table_name} no longer exist in the current data source"
        end
      end

      desc "Import data for all USGeo models"
      task all: :environment do
        klasses.each_key do |name|
          Rake::Task["us_geo:import:#{name}"].invoke
        end
      end
    end

    desc "List the number of records from previously imported data that no longer exists in the current data source"
    task removed_counts: :environment do
      klasses.each_value do |klass|
        removed_count = klass.removed.count
        puts "#{klass.table_name}: #{removed_count} previously imported records no longer exist in the current data source"
      end
    end

    desc "Dump the data for all records from previously imported data that no longer exists in the current data source to JSON"
    task dump_removed: :environment do
      require "json"

      puts "{"
      klasses.each_value do |klass|
        puts "  \"#{klass.table_name}\": ["
        klass.removed.find_each do |record|
          row_json JSON.dump(record.attributes.except("status", "updated_at"))
          puts "#{row_json},"
        end
        puts "]"
      end
      puts "}"
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
