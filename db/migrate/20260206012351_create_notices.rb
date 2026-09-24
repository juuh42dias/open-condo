class CreateNotices < ActiveRecord::Migration[7.2]
  def change
    create_table :notices do |t|
      t.string :title
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :building, null: false, foreign_key: true
      t.string :priority
      t.datetime :published_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
