class CreateResidents < ActiveRecord::Migration[7.2]
  def change
    create_table :residents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.date :move_in_date
      t.date :move_out_date

      t.timestamps
    end
  end
end
