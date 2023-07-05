class AddTypeToDemos < ActiveRecord::Migration[7.0]
  def change
    add_column :demos, :type, :string
  end
end
