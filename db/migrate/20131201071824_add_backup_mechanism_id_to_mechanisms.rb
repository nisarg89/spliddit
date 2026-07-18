class AddBackupMechanismIdToMechanisms < ActiveRecord::Migration[7.0]
  def change
    add_column :mechanisms, :backup_mechanism_id, :integer
  end
end
