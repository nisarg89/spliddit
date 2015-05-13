class AddInstancesCount < ActiveRecord::Migration
  def change
    add_column :applications, :instances_count, :integer, :default => 0
  end

end
