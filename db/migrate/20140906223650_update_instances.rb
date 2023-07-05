class UpdateInstances < ActiveRecord::Migration[7.0]
  def change
      remove_column :instances, :mechanism
      remove_column :instances, :mechanism_id
      add_column :instances, :application_id, :int
  end
end
