class AbbrForMechanisms < ActiveRecord::Migration[7.0]
  def change
    add_column :mechanisms, :abbr, :string
  end
end
