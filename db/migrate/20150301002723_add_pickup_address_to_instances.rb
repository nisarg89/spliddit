class AddPickupAddressToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :pickup_address, :string
  end
end
