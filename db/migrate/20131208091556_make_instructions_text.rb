class MakeInstructionsText < ActiveRecord::Migration[7.0]
  def change
    change_column :problems, :instructions, :text
  end
end
