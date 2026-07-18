class DropDemos < ActiveRecord::Migration[7.0]
  def change
    drop_table :demos
  end
end
