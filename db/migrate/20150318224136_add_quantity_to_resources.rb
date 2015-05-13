class AddQuantityToResources < ActiveRecord::Migration
  def change
    add_column :resources, :quantity, :integer
  end
end
