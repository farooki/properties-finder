class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :displayname
      t.string :locationidentifier
      t.string :normalisedsearchierm
      t.jsonb :settings, default: {}

      t.timestamps
    end
    add_index :locations, [:displayname],  unique: true
  end
end
