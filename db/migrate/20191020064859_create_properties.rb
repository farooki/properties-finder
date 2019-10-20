class CreateProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :properties do |t|
      t.string :name
      t.string :description
      t.jsonb :images
      t.float :price
      t.string :source

      t.timestamps
    end
  end
end
