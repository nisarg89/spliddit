class IntegerRent < ActiveRecord::Migration[7.0]
  def change
    change_column :instances, :rent, :integer
  end
end
