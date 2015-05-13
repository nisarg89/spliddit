class RemoveAdminPasscodeFromInstances < ActiveRecord::Migration
  def change
    remove_column :instances, :admin_passcode
  end
end
