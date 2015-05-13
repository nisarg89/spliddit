class AddAdminEmailPasscodeToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :admin_email, :string
    add_column :instances, :admin_passcode, :string
  end
end
