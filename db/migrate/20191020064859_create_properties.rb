class CreateProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :properties do |t|
      t.string :name
      t.text :description
      t.jsonb :images
      t.float :price
      t.string :source
      t.string :source_url

      t.timestamps
    end
    add_index :properties, [:source_url],  unique: true
  end
end
