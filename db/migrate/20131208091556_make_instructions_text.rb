class MakeInstructionsText < ActiveRecord::Migration
  def change
    change_column :problems, :instructions, :text
  end
end
