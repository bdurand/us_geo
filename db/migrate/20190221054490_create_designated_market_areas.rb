class CreateDesignatedMarketAreas < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_designated_market_areas, id: false do |t|
      t.string :code, primary_key: true, null: false, limit: 3
      t.string :name, null: false, limit: 60, index: {unique: true}
      t.datetime :updated_at, null: false
      t.integer :status, null: false, default: 0, limit: 1
    end
  end

  def down
    drop_table :us_geo_designated_market_areas
  end

end
