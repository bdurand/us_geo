# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_04_19_234279) do
  create_table "us_geo_combined_statistical_areas", primary_key: "geoid", id: { type: :string, limit: 3 }, force: :cascade do |t|
    t.string "name", limit: 60, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.integer "population", null: false
    t.integer "housing_units", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.string "short_name", null: false
    t.index ["name"], name: "index_us_geo_combined_statistical_areas_on_name", unique: true
    t.index ["short_name"], name: "index_us_geo_combined_statistical_areas_on_short_name", unique: true
  end

  create_table "us_geo_core_based_statistical_areas", primary_key: "geoid", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.string "csa_geoid", limit: 5
    t.string "name", limit: 60, null: false
    t.string "type", limit: 30, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.integer "population", null: false
    t.integer "housing_units", null: false
    t.float "lat", null: false
    t.float "lng", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.string "short_name", null: false
    t.index ["csa_geoid"], name: "index_us_geo_core_based_statistical_areas_on_csa_geoid"
    t.index ["name"], name: "index_us_geo_core_based_statistical_areas_on_name", unique: true
    t.index ["short_name"], name: "index_us_geo_core_based_statistical_areas_on_short_name", unique: true
  end

  create_table "us_geo_counties", primary_key: "geoid", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.integer "gnis_id", null: false
    t.string "cbsa_geoid", limit: 5
    t.string "metropolitan_division_geoid", limit: 5
    t.string "name", limit: 60, null: false
    t.string "short_name", limit: 30, null: false
    t.string "state_code", limit: 2, null: false
    t.boolean "central", default: false
    t.string "fips_class_code", limit: 2, null: false
    t.string "time_zone_name", limit: 30
    t.float "land_area"
    t.float "water_area"
    t.integer "population"
    t.integer "housing_units"
    t.float "lat"
    t.float "lng"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["cbsa_geoid"], name: "index_us_geo_counties_on_cbsa_geoid"
    t.index ["gnis_id"], name: "index_us_geo_counties_on_gnis_id"
    t.index ["metropolitan_division_geoid"], name: "index_us_geo_counties_on_metropolitan_division_geoid"
    t.index ["name", "state_code"], name: "index_us_geo_counties_on_name_and_state_code", unique: true
    t.index ["short_name", "state_code"], name: "index_us_geo_counties_on_short_name_and_state_code", unique: true
    t.index ["state_code"], name: "index_us_geo_counties_on_state_code"
  end

  create_table "us_geo_county_subdivisions", primary_key: "geoid", id: { type: :string, limit: 10 }, force: :cascade do |t|
    t.integer "gnis_id", null: false
    t.string "name", limit: 60, null: false
    t.string "county_geoid", limit: 5, null: false
    t.string "fips_class_code", limit: 2, null: false
    t.float "land_area"
    t.float "water_area"
    t.integer "population"
    t.integer "housing_units"
    t.float "lat", null: false
    t.float "lng", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["county_geoid"], name: "index_us_geo_county_subdivisions_on_county_geoid"
    t.index ["gnis_id"], name: "index_us_geo_county_subdivisions_on_gnis_id"
    t.index ["name", "county_geoid"], name: "index_us_geo_county_subdivisions_on_unique_name", unique: true
  end

  create_table "us_geo_divisions", force: :cascade do |t|
    t.integer "region_id", limit: 1, null: false
    t.string "name", limit: 30, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.float "land_area"
    t.float "water_area"
    t.integer "population"
    t.integer "housing_units"
    t.index ["name"], name: "index_us_geo_divisions_on_name", unique: true
    t.index ["region_id"], name: "index_us_geo_divisions_on_region_id"
  end

  create_table "us_geo_metropolitan_divisions", primary_key: "geoid", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.string "cbsa_geoid", limit: 5
    t.string "name", limit: 60, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.integer "population", null: false
    t.integer "housing_units", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["cbsa_geoid"], name: "index_us_geo_metropolitan_divisions_on_cbsa_geoid"
    t.index ["name"], name: "index_us_geo_metropolitan_divisions_on_name", unique: true
  end

  create_table "us_geo_place_counties", force: :cascade do |t|
    t.string "place_geoid", limit: 7, null: false
    t.string "county_geoid", limit: 5, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["county_geoid"], name: "index_us_geo_place_counties_on_county_geoid"
    t.index ["place_geoid", "county_geoid"], name: "index_us_geo_place_counties_uniq", unique: true
  end

  create_table "us_geo_places", primary_key: "geoid", id: { type: :string, limit: 7 }, force: :cascade do |t|
    t.integer "gnis_id", null: false
    t.string "name", limit: 60, null: false
    t.string "short_name", limit: 30, null: false
    t.string "state_code", limit: 2, null: false
    t.string "primary_county_geoid", limit: 5, null: false
    t.string "urban_area_geoid", limit: 5
    t.string "fips_class_code", limit: 2, null: false
    t.float "land_area"
    t.float "water_area"
    t.integer "population"
    t.integer "housing_units"
    t.float "lat", null: false
    t.float "lng", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["gnis_id"], name: "index_us_geo_places_on_gnis_id"
    t.index ["name"], name: "index_us_geo_places_on_name"
    t.index ["primary_county_geoid"], name: "index_us_geo_places_on_primary_county_geoid"
    t.index ["short_name"], name: "index_us_geo_places_on_short_name"
    t.index ["state_code"], name: "index_us_geo_places_on_state_code"
    t.index ["urban_area_geoid"], name: "index_us_geo_places_on_urban_area_geoid"
  end

  create_table "us_geo_regions", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.float "land_area"
    t.float "water_area"
    t.integer "population"
    t.integer "housing_units"
    t.index ["name"], name: "index_us_geo_regions_on_name", unique: true
  end

  create_table "us_geo_states", primary_key: "code", id: { type: :string, limit: 2 }, force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "fips", limit: 2, null: false
    t.string "type", limit: 30, null: false
    t.integer "region_id", limit: 1
    t.integer "division_id", limit: 1
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.float "land_area"
    t.float "water_area"
    t.integer "population"
    t.integer "housing_units"
    t.index ["division_id"], name: "index_us_geo_states_on_division_id"
    t.index ["fips"], name: "index_us_geo_states_on_fips", unique: true
    t.index ["name"], name: "index_us_geo_states_on_name", unique: true
    t.index ["region_id"], name: "index_us_geo_states_on_region_id"
  end

  create_table "us_geo_urban_area_counties", force: :cascade do |t|
    t.string "urban_area_geoid", limit: 5, null: false
    t.string "county_geoid", limit: 5, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["county_geoid"], name: "index_us_geo_urban_area_counties_on_county_geoid"
    t.index ["urban_area_geoid", "county_geoid"], name: "index_us_geo_urban_area_counties_uniq", unique: true
  end

  create_table "us_geo_urban_area_county_subdivisions", force: :cascade do |t|
    t.string "urban_area_geoid", limit: 5, null: false
    t.string "county_subdivision_geoid", limit: 10, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["county_subdivision_geoid"], name: "index_us_geo_urban_area_county_subdivisions_geoid"
    t.index ["urban_area_geoid", "county_subdivision_geoid"], name: "index_us_geo_urban_area_county_subdivisions_uniq", unique: true
  end

  create_table "us_geo_urban_areas", primary_key: "geoid", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.string "name", limit: 90, null: false
    t.string "short_name", limit: 60, null: false
    t.string "primary_county_geoid", limit: 5, null: false
    t.string "type", limit: 30, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.integer "population", null: false
    t.integer "housing_units", null: false
    t.float "lat", null: false
    t.float "lng", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["name"], name: "index_us_geo_urban_areas_on_name", unique: true
    t.index ["primary_county_geoid"], name: "index_us_geo_urban_areas_on_primary_county_geoid"
    t.index ["short_name"], name: "index_us_geo_urban_areas_on_short_name", unique: true
  end

  create_table "us_geo_zcta_counties", force: :cascade do |t|
    t.string "zipcode", limit: 5, null: false
    t.string "county_geoid", limit: 5, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.integer "population"
    t.integer "housing_units"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["county_geoid"], name: "index_us_geo_zcta_counties_on_county_geoid"
    t.index ["zipcode", "county_geoid"], name: "index_us_geo_zcta_counties_uniq", unique: true
  end

  create_table "us_geo_zcta_county_subdivisions", force: :cascade do |t|
    t.string "zipcode", limit: 5, null: false
    t.string "county_subdivision_geoid", limit: 10, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["county_subdivision_geoid"], name: "index_us_geo_zcta_county_subdivisions_on_geoid"
    t.index ["zipcode", "county_subdivision_geoid"], name: "index_us_geo_zcta_county_subdivisions_uniq", unique: true
  end

  create_table "us_geo_zcta_mappings", primary_key: "zipcode", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.string "zcta_zipcode", limit: 5, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["zcta_zipcode"], name: "index_us_geo_zcta_mappings_on_zcta_zipcode"
  end

  create_table "us_geo_zcta_places", force: :cascade do |t|
    t.string "zipcode", limit: 5, null: false
    t.string "place_geoid", limit: 7, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["place_geoid"], name: "index_us_geo_zcta_places_on_place_geoid"
    t.index ["zipcode", "place_geoid"], name: "index_us_geo_us_geo_zcta_places_uniq", unique: true
  end

  create_table "us_geo_zcta_urban_areas", force: :cascade do |t|
    t.string "zipcode", limit: 5, null: false
    t.string "urban_area_geoid", limit: 5, null: false
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.index ["urban_area_geoid", "zipcode"], name: "index_us_geo_urban_area_zctas_uniq", unique: true
    t.index ["zipcode"], name: "index_us_geo_zcta_urban_areas_on_zipcode"
  end

  create_table "us_geo_zctas", primary_key: "zipcode", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.string "primary_county_geoid", limit: 5, null: false
    t.string "primary_urban_area_geoid", limit: 5
    t.float "land_area", null: false
    t.float "water_area", null: false
    t.integer "population", null: false
    t.integer "housing_units", null: false
    t.float "lat", null: false
    t.float "lng", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", limit: 1, default: 0, null: false
    t.string "primary_place_geoid", limit: 7
    t.string "primary_county_subdivision_geoid", limit: 10
    t.index ["primary_county_geoid"], name: "index_us_geo_zctas_on_primary_county_geoid"
    t.index ["primary_urban_area_geoid"], name: "index_us_geo_zctas_on_primary_urban_area_geoid"
  end

end
