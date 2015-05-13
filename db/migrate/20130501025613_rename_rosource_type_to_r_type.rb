class RenameRosourceTypeToRType < ActiveRecord::Migration
  def up
    rename_column :resources, :type, :rtype
  end

  def down
  end
end
