class NoInstructionsLimit < ActiveRecord::Migration
  def change
    change_column :problems, :instructions, :text, :limit => nil
  end
end
