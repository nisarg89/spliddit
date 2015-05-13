class AddSendResultsToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :send_results, :boolean
  end
end
