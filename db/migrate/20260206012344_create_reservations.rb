class CreateReservations < ActiveRecord::Migration[7.2]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :common_area, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :status
      t.decimal :total_cost

      t.timestamps
    end
  end
end
