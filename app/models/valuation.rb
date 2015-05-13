class Valuation < ActiveRecord::Base
  attr_accessible :value

  validate :value_in_range
  belongs_to :instance
  belongs_to :agent
  belongs_to :resource

  def value_in_range
    if value < instance.min_bid
      errors.add(:value, "Must be at least #{instance.min_bid}")
    end
  end

end