class CreateRegions < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_regions, id: false do |t|
      t.integer :id, primary_key: true, null: false, limit: 1
      t.string :name, null: false, limit: 30, index: {unique: true}
      t.datetime :updated_at, null: false
      t.boolean :removed, null: false, default: false
    end
  end

  def down
    drop_table :us_geo_regions
  end

end
