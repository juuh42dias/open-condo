class CreatePackages < ActiveRecord::Migration[7.2]
  def change
    create_table :packages do |t|
      t.references :unit, null: false, foreign_key: true
      t.string :recipient_name, null: false
      t.string :sender
      t.string :carrier
      t.string :tracking_code
      t.string :status, null: false, default: "received"
      t.datetime :received_at
      t.datetime :notified_at
      t.datetime :picked_up_at
      t.text :notes

      t.timestamps
    end

    add_index :packages, :status
    add_index :packages, :tracking_code
  end
end
