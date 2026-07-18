class CreateResources < ActiveRecord::Migration[7.0]
  def change
    create_table :resources do |t|
      t.string :name
      t.string :type
      t.string :description
      t.integer :mechanism_instance_id
      t.string :mechanism_instance_type
      t.timestamps
    end
  end
end
