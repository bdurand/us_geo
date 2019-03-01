class CreateStates < ActiveRecord::Migration[5.0]

  def up
    create_table :us_geo_states, id: false do |t|
      t.string :code, primary_key: true, null: false, limit: 2
      t.string :name, null: false, limit: 30, index: {unique: true}
      t.string :fips, null: false, limit: 2, index: {unique: true}
      t.string :type, null: false, limit: 30
      t.integer :region_id, null: true, limit: 1, index: true
      t.integer :division_id, null: true, limit: 1, index: true
      t.datetime :updated_at, null: false
      t.boolean :removed, null: false, default: false
    end
  end

  def down
    drop_table :us_geo_states
  end

end
