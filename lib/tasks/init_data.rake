namespace :db do

  task clear_all: :environment do
    Application.delete_all
    Instance.delete_all
    Agent.delete_all
    Resource.delete_all
  end

  task init_data: :environment do

    app = Application.find("rent") || Application.new(abbr: "rent")
    app.name = "Share Rent"
    app.save

    app = Application.find("goods") || Application.new(abbr: "goods")
    app.name = "Divide Goods"
    app.save

    app = Application.find("credit") || Application.new(abbr: "credit")
    app.name = "Assign Credit"
    app.save

    app = Application.find("fare") || Application.new(abbr: "fare")
    app.name = "Split Fare"
    app.save

    app = Application.find("tasks") || Application.new(abbr: "tasks")
    app.name = "Distribute Tasks"
    app.save

    Application.all.each do |a|
      Application.reset_counters(a.abbr, :instances)
    end
  end
end