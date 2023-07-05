class AddStatusToInstance < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :status, :string, default: "waiting"
    remove_column :instances, :resultsJSON
  end
end
