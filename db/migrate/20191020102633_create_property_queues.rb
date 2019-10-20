class CreatePropertyQueues < ActiveRecord::Migration[6.0]
  def change
    create_table :property_queues do |t|
      t.integer :location_id
      t.float :radius
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
