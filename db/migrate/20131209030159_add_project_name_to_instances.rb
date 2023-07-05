class AddProjectNameToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :project_name, :string
  end
end
