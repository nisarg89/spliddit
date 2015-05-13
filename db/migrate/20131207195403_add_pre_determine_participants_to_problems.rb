class AddPreDetermineParticipantsToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :predetermine_participants, :boolean, default: true
  end
end
