class MakeUsesDefaultToZeroInProblemsTable < ActiveRecord::Migration
  def up
    remove_column :problems, :uses
    add_column :problems, :uses, :integer, default: 0
  end

  def down
    remove_column :problems, :uses
    add_column :problems, :uses, :integer
  end
end
