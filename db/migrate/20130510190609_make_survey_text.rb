class MakeSurveyText < ActiveRecord::Migration[7.0]
  def up
    change_column :agents, :feedback, :text
  end
  
  def down
    change_column :agents, :feedback, :text
  end
end
