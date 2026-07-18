class NoInstructionsLimit < ActiveRecord::Migration[7.0]
  def change
    change_column :problems, :instructions, :text, :limit => nil
  end
end
