class AddCurrencyToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :currency, :string
  end
end
