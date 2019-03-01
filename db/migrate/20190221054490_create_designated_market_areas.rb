class CreateDesignatedMarketAreas < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_designated_market_areas, id: false do |t|
      t.string :code, primary_key: true, null: false, limit: 3
      t.string :name, null: false, limit: 60, index: {unique: true}
      t.datetime :updated_at, null: false
      t.boolean :removed, null: false, default: false
    end
  end

  def down
    drop_table :us_geo_designated_market_areas
  end

end
