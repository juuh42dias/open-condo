class CreateCommonAreas < ActiveRecord::Migration[7.2]
  def change
    create_table :common_areas do |t|
      t.string :name
      t.string :description
      t.integer :capacity
      t.decimal :hourly_rate
      t.references :building, null: false, foreign_key: true

      t.timestamps
    end
  end
end
