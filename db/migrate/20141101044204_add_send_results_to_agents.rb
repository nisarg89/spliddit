class AddSendResultsToAgents < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :send_results, :boolean
  end
end
