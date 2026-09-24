class CreateMaintenanceRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :maintenance_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :priority
      t.string :status
      t.datetime :completed_at

      t.timestamps
    end
  end
end
