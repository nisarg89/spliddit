class RenameProblemsToApplications < ActiveRecord::Migration[7.0]
  def change
    rename_table :problems, :applications
  end
end
