class AddProjectNameToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :project_name, :string
  end
end
