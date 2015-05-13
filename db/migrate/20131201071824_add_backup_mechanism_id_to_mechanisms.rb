class AddBackupMechanismIdToMechanisms < ActiveRecord::Migration
  def change
    add_column :mechanisms, :backup_mechanism_id, :integer
  end
end
