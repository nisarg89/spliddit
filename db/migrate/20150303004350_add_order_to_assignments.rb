class AddOrderToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :order, :integer
  end
end
