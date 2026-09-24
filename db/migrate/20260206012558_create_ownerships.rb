class CreateOwnerships < ActiveRecord::Migration[7.2]
  def change
    create_table :ownerships do |t|
      t.references :owner, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.decimal :ownership_percentage

      t.timestamps
    end
  end
end
