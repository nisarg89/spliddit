class AddOrderToAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :assignments, :order, :integer
  end
end
