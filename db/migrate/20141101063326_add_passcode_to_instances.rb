class AddPasscodeToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :passcode, :string
  end
end
