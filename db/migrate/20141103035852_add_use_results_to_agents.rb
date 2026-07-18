class AddUseResultsToAgents < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :use_results, :integer
  end
end
