class AddErrorMessageToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :error_message, :string
  end
end
