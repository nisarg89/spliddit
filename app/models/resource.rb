class Resource < ActiveRecord::Base
  attr_accessible :name, :rtype, :description, :quantity

  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :rtype, length: { maximum: 50 }
  validates :description, length: { maximum: 200 }
  validates :quantity, numericality: {greater_than_or_equal: 1, less_than: 1000000}, allow_nil: true

  belongs_to :instance

  has_many :valuations
  has_many :valuation_agent, through: :valuations, class_name: "Agent"

  has_many :assignments
  has_many :assignees, through: :assignments, class_name: "Agent"

  default_scope { order('id ASC') }
end
