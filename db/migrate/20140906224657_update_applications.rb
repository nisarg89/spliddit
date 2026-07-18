class UpdateApplications < ActiveRecord::Migration[7.0]
  def change
    remove_column :applications, :description
    remove_column :applications, :short_description
    remove_column :applications, :instructions
    remove_column :applications, :predetermine_participants
  end
end
