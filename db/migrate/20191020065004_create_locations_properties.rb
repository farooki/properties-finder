class CreateLocationsProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :locations_properties do |t|
      t.references :location, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.float :radius
      t.boolean :is_active

      t.timestamps
    end
  end
end
