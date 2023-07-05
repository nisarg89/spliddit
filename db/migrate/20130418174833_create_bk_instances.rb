class CreateBkInstances < ActiveRecord::Migration[7.0]
  def change
    create_table :bk_instances do |t|
      t.decimal :rent, :precision => 10, :scale => 2
      t.string :resultsJSON
      t.boolean :init_email_sent, default: false
      t.boolean :results_email_sent, default: false

      t.timestamps
    end
  end
end
