class InitInstancesCount2 < ActiveRecord::Migration
  def change
    Application.all.each do |a|
      Application.reset_counters(a.abbr, :instances)
    end
  end
end
