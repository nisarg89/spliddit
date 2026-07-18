class AddImageAndShortDescriptionToProblemsTable < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :image_url, :string
    add_column :problems, :short_description, :string
  end
end
