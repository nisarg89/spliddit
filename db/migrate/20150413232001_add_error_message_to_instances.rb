class AddErrorMessageToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :error_message, :string
  end
end
