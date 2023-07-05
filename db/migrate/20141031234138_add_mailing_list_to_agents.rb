class AddMailingListToAgents < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :mailing_list, :boolean
  end
end
