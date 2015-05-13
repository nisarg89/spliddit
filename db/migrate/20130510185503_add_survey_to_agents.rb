class AddSurveyToAgents < ActiveRecord::Migration
  def up
    add_column :agents, :satisfaction, :integer
    add_column :agents, :feedback, :string
  end

  def down
    remove_column :agents, :satisfaction
    remove_column :agents, :feedback
  end
end
