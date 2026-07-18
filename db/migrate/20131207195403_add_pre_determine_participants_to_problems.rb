class AddPreDetermineParticipantsToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :predetermine_participants, :boolean, default: true
  end
end
