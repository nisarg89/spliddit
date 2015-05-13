class AddAbbrToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :abbr, :string
  end
end
