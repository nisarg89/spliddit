class DropOldInstancesTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :asu_instances
    drop_table :bk_instances
    drop_table :ceei_instances
    drop_table :ee_instances
    drop_table :leaders_instances
    drop_table :sci_cred_instances
  end
end
