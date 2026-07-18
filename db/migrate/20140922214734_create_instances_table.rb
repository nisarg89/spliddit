class CreateInstancesTable < ActiveRecord::Migration[7.0]
  def change
    create_table "instances", :force => true do |t|
      t.boolean  "init_email_sent",                  :default => false
      t.boolean  "results_email_sent",               :default => false
      t.string   "type"
      t.string   "resultsJSON"
      t.datetime "created_at",                                          :null => false
      t.datetime "updated_at",                                          :null => false
      t.integer  "rent",               :limit => 10
      t.string   "apartment_name"
      t.string   "project_name"
      t.integer  "application_id"
      t.boolean  "separate_passwords", :default => false
    end
  end
end
