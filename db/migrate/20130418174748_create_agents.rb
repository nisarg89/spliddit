class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :name
      t.string :email
      t.string :valuationJSON
      t.string :ip_address
      t.string :passcode
      t.integer :mechanism_instance_id
      t.string :mechanism_instance_type
      t.timestamps
    end
  end
end
