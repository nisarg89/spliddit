class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :mechanism
      t.boolean :init_email_sent, default: false
      t.boolean :results_email_sent, default: false
      t.string :type
      t.string :resultsJSON

      t.timestamps
    end
  end
end
