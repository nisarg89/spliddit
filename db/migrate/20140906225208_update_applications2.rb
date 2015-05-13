class UpdateApplications2 < ActiveRecord::Migration
  def change
    remove_column :applications, :image_url
  end
end
