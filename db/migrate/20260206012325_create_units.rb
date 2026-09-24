class CreateUnits < ActiveRecord::Migration[7.2]
  def change
    create_table :units do |t|
      t.string :unit_number
      t.references :building, null: false, foreign_key: true
      t.string :unit_type
      t.integer :bedrooms
      t.integer :bathrooms
      t.decimal :area
      t.string :status

      t.timestamps
    end
  end
end
