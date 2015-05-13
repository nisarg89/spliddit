class MakeSurveyText < ActiveRecord::Migration
  def up
    change_column :agents, :feedback, :text
  end
  
  def down
    change_column :agents, :feedback, :text
  end
end
