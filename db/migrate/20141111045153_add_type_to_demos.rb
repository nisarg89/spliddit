class AddTypeToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :type, :string
  end
end
