class IntegerRent < ActiveRecord::Migration
  def change
    change_column :instances, :rent, :integer
  end
end
