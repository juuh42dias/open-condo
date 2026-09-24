class AddCheckinFieldsToVisitors < ActiveRecord::Migration[7.2]
  def change
    add_column :visitors, :approved_at, :datetime
    add_column :visitors, :checked_in_at, :datetime
    add_column :visitors, :checked_out_at, :datetime
  end
end
