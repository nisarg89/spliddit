class AddQuantityToResources < ActiveRecord::Migration[7.0]
  def change
    add_column :resources, :quantity, :integer
  end
end
