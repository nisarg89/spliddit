class AddApartmentToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :apartment_name, :string
  end
end
