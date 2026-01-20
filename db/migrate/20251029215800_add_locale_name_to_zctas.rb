class AddLocaleNameToZctas < ActiveRecord::Migration[5.0]
  def change
    add_column :us_geo_zctas, :usps_locality, :string, limit: 30, null: true
    add_column :us_geo_zctas, :usps_state_code, :string, limit: 2, null: true
  end
end
