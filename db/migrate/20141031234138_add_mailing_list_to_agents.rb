class AddMailingListToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :mailing_list, :boolean
  end
end
