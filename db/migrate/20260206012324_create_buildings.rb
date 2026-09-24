class CreateBuildings < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings do |t|
      t.string :name
      t.string :address
      t.text :description
      t.integer :total_units

      t.timestamps
    end
  end
end
