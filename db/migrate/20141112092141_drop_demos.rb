class DropDemos < ActiveRecord::Migration
  def change
    drop_table :demos
  end
end
