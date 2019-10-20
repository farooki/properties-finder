class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :displayName
      t.string :locationIdentifier
      t.string :normalisedSearchTerm
      t.jsonb :settings, default: {}

      t.timestamps
    end
    add_index :locations, [:displayName],  unique: true
  end
end
