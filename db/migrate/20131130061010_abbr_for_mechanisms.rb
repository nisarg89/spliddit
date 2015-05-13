class AbbrForMechanisms < ActiveRecord::Migration
  def change
    add_column :mechanisms, :abbr, :string
  end
end
