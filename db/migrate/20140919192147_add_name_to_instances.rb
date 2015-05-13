class AddNameToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :name, :string
    remove_column :instances, :project_name
    remove_column :instances, :apartment_name
  end
end
