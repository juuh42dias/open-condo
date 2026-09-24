class AddCategoryToMaintenanceRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :maintenance_requests, :category, :string
    add_index :maintenance_requests, :category
  end
end
