class AddAdminEmailPasscodeToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :admin_email, :string
    add_column :instances, :admin_passcode, :string
  end
end
