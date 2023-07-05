class AddCounterToProblemTable < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :uses, :integer
    add_column :problems, :single_use, :string
    add_column :problems, :multi_use, :string
  end
end
