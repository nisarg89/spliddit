class AddImageAndShortDescriptionToProblemsTable < ActiveRecord::Migration
  def change
    add_column :problems, :image_url, :string
    add_column :problems, :short_description, :string
  end
end
