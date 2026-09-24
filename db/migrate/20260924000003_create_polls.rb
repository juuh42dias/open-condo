class CreatePolls < ActiveRecord::Migration[7.2]
  def change
    create_table :polls do |t|
      t.references :building, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "open"
      t.datetime :closes_at

      t.timestamps
    end

    create_table :poll_options do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :text, null: false
      t.integer :votes_count, null: false, default: 0

      t.timestamps
    end

    create_table :votes do |t|
      t.references :poll, null: false, foreign_key: true
      t.references :poll_option, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :votes, %i[poll_id user_id], unique: true
    add_index :polls, :status
  end
end
