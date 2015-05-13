class AddUseResultsToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :use_results, :integer
  end
end
