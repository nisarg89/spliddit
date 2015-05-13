class CreateCeeiInstances < ActiveRecord::Migration
  def change
    create_table :ceei_instances do |t|
      t.string :resultsJSON
      t.boolean :init_email_sent, default: false
      t.boolean :results_email_sent, default: false
      t.timestamps
    end
  end
end
