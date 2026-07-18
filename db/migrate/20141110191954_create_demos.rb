class CreateDemos < ActiveRecord::Migration[7.0]
  def change
    create_table :demos do |t|
      t.integer :application_id
      t.string :ip
      t.string :input
      t.string :output
      t.string :status, default: "waiting"

      t.timestamps
    end
  end
end
