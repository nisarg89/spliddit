class Agent < ActiveRecord::Base
  attr_accessible :name, :email, :mailing_list, :send_results, :passcode, :fairness_str

  validate :empty_or_valid_email

  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :email, length: { maximum: 100 }

  validates :feedback, length: { maximum: 1000 }

  belongs_to :instance

  has_many :valuations
  has_many :valuation_resources, through: :valuations, class_name: "Resource"

  has_many :assignments
  has_many :assigned_resources, through: :assignments, class_name: "Resource"

  scope :by_password, lambda { |pwd| where("agents.passcode = (?)",pwd) }

  default_scope { order('id ASC') }

  def submitted_survey?
    satisfaction != nil
  end

  def empty_or_valid_email
    if email != nil and email.length > 0 and !ValidateEmail.mx_valid?(email)
      errors.add(:email, "Invalid email address")
    end
  end
end
