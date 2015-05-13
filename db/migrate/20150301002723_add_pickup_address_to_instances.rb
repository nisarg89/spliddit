class AddPickupAddressToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :pickup_address, :string
  end
end
