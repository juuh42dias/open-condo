class CreateVisitors < ActiveRecord::Migration[7.2]
  def change
    create_table :visitors do |t|
      t.string :name
      t.string :id_number
      t.string :phone
      t.date :visit_date
      t.datetime :visit_time
      t.references :resident, null: false, foreign_key: true
      t.string :purpose
      t.boolean :approved

      t.timestamps
    end
  end
end
