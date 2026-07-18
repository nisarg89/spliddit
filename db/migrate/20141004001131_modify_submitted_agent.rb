class ModifySubmittedAgent < ActiveRecord::Migration[7.0]
  def change
    change_column :agents, :submitted, :boolean, default: false
  end
end
