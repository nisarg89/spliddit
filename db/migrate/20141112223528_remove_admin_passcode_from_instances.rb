class RemoveAdminPasscodeFromInstances < ActiveRecord::Migration[7.0]
  def change
    remove_column :instances, :admin_passcode
  end
end
