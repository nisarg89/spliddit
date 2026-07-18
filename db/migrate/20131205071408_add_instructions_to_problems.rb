class AddInstructionsToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :instructions, :string
  end
end
