class AddNameToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :name, :string
    remove_column :instances, :project_name
    remove_column :instances, :apartment_name
  end
end
