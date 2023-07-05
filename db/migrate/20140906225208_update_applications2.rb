class UpdateApplications2 < ActiveRecord::Migration[7.0]
  def change
    remove_column :applications, :image_url
  end
end
