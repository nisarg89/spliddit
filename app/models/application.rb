class Application < ActiveRecord::Base
  #attr_accessible :name, :abbr, :instances_count
  def application_params
    params.require(:application).permit(:name, :abbr, :instances_count)
  end

  validates :abbr, presence: true, length: { minimum: 1, maximum: 20 }
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }

  has_many :instances

  def to_param
    abbr
  end

  def self.find(input)
    find_by_abbr(input)
  end

end

