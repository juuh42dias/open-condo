class CreateOwners < ActiveRecord::Migration[7.2]
  def change
    create_table :owners do |t|
      t.references :user, null: false, foreign_key: true
      t.text :units_owned

      t.timestamps
    end
  end
end
