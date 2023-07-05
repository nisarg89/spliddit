class AddPasscodeToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :passcode, :string
  end
end
