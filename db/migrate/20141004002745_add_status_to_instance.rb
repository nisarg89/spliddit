class AddStatusToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :status, :string, default: "waiting"
    remove_column :instances, :resultsJSON
  end
end
