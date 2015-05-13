class CreateMechanisms < ActiveRecord::Migration
  def change
    create_table :mechanisms do |t|
      t.string :name
      t.string :description
      t.string :link
      t.integer :problem_id
      t.timestamps
    end
  end
end
