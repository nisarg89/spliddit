class FixInstanceNameColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :instances, :apartment_name
    remove_column :instances, :project_name
    add_column :instances, :name, :string
  end
end
