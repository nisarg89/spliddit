class AddInstructionsToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :instructions, :string
  end
end
