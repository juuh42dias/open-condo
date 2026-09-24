class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.decimal :amount
      t.string :payment_type
      t.date :due_date
      t.datetime :paid_at
      t.string :status
      t.string :description

      t.timestamps
    end
  end
end
