class AddApartmentToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :apartment_name, :string
  end
end
