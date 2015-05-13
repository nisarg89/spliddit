class ModifySubmittedAgent < ActiveRecord::Migration
  def change
    change_column :agents, :submitted, :boolean, default: false
  end
end
