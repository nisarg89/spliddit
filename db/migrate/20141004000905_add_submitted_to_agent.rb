class AddSubmittedToAgent < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :submitted, :boolean
    remove_column :agents, :valuationJSON
  end
end
