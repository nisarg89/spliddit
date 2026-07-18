class RemoveLimitForDescription < ActiveRecord::Migration[7.0]
  def change
    change_column :agents, :feedback, :text, :limit => nil
    change_column :mechanisms, :description, :text, :limit => nil
    change_column :problems, :description, :text, :limit => nil
  end
end
