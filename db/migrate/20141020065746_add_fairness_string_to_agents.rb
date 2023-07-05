class AddFairnessStringToAgents < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :fairness_str, :text
  end
end
