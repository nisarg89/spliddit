class RenameRosourceTypeToRType < ActiveRecord::Migration[7.0]
  def up
    rename_column :resources, :type, :rtype
  end

  def down
  end
end
