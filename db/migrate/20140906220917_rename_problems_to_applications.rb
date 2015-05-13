class RenameProblemsToApplications < ActiveRecord::Migration
  def change
    rename_table :problems, :applications
  end
end
