class CreateViolations < ActiveRecord::Migration[7.2]
  def change
    create_table :violations do |t|
      t.references :unit, null: false, foreign_key: true
      t.references :reported_by, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description, null: false
      t.string :violation_type, null: false, default: "other"
      t.string :severity, null: false, default: "medium"
      t.string :status, null: false, default: "open"
      t.decimal :fine_amount, precision: 10, scale: 2, default: 0.0
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :violations, :status
    add_index :violations, :violation_type
  end
end
