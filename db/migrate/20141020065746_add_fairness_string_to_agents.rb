class AddFairnessStringToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :fairness_str, :text
  end
end
