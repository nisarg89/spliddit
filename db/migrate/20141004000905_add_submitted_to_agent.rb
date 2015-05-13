class AddSubmittedToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :submitted, :boolean
    remove_column :agents, :valuationJSON
  end
end
