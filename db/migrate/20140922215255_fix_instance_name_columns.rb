class FixInstanceNameColumns < ActiveRecord::Migration
  def change
    remove_column :instances, :apartment_name
    remove_column :instances, :project_name
    add_column :instances, :name, :string
  end
end
