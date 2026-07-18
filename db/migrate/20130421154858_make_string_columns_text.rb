class MakeStringColumnsText < ActiveRecord::Migration[7.0]
  def up
      change_column :problems, :description, :text
      change_column :mechanisms, :description, :text
      change_column :mech_properties, :definition, :text
  end
  def down
      # This might cause trouble if you have strings longer
      # than 255 characters.
      change_column :problems, :description, :string
      change_column :mechanisms, :description, :string
      change_column :mech_properties, :definition, :string
  end
end
