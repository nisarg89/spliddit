class AddCurrencyToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :currency, :string
  end
end
