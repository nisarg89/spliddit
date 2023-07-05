class CreateSciCredInstances < ActiveRecord::Migration[7.0]
  def change
    create_table :sci_cred_instances do |t|
      t.string :resultsJSON
      t.boolean :init_email_sent, default: false
      t.boolean :results_email_sent, default: false
      t.timestamps
    end
  end
end
