class AddAbbrToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :abbr, :string
  end
end
