class Instance < ActiveRecord::Base
  # attr_accessible :name, :separate_passwords, :passcode, :admin_email, :status
  def instance_params
    params.require(:instance).permit(:name, :separate_passwords, :passcode, :admin_email, :status)
  end

  has_many :instances, class_name: 'Instance'

  has_many :agents, dependent: :destroy
  validates_associated :agents

  has_many :resources, dependent: :destroy
  validates_associated :resources

  has_many :valuations, dependent: :destroy

  has_many :assignments, dependent: :destroy

  belongs_to :application, :counter_cache => true

  after_create :send_init_emails

  validates :name, presence: true, length: { maximum: 100 }
  validates :type, presence: true
  validates :admin_email, length: { maximum: 100 }

  validate :unique_agent_names
  validate :non_empty_emails_if_separate_passwords
  validate :unique_resource_names
  validate :empty_or_valid_admin_email
  validate :agent_count
  validate :resource_count
  validate :resource_types

  def admin
    agents.each { |a| return a if a.admin }
    return nil
  end

  # All valuations submitted and the algorithm hasn't run
  def pending?
    return false if status != "waiting"
    agents.each do |a|
      return false if !a.submitted
    end
    return true
  end

  # Algorithm successful
  def complete?
    status == "complete"
  end

  # Algorithm failed
  def failed?
    status == "failure"
  end

  def send_init_emails
    Delayed::Job.enqueue InitEmailJob.new(id)
  end

  def run(attempt)
    update_attribute(:status, "failure")
  end

  def empty_or_valid_admin_email
    if admin_email != nil and admin_email.length > 0 and !ValidateEmail.mx_valid?(admin_email)
      errors.add(:admin_email, "Invalid email address")
    end
  end

  def unique_agent_names
    if (agents.map { |a| a.name}).uniq.count < agents.count
      errors.add(:agents, "Duplicate names")
    end
  end

  def non_empty_emails_if_separate_passwords
    if separate_passwords
      agents.each do |a|
        if !a.email || a.email == ""
          errors.add(:agents, "Email must be provided")
        end
      end
    end
  end

  def unique_resource_names
    if (resources.map { |a| a.name}).uniq.count < resources.count
      errors.add(:resources, "Duplicate resource names")
    end
  end

  def agent_count
    if agents.size < min_agents
      errors.add(:agents, "Minimum of #{min_agents} participants")
    end
    if agents.size > max_agents
      errors.add(:agents, "Maximum of #{max_agents} participants")
    end
  end

  def resource_count
    if resources.size < min_resources
      errors.add(:resources, "Minimum of #{min_resources} resources")
    end
    if resources.size > max_resources
      errors.add(:resources, "Maximum of #{max_resources} resources")
    end
  end

  def resource_types
    resources.each do |r|
      if !resource_types.include? r.rtype
        errors.add(:resources, "Invalid resource type #{r.rtype}")
      end
    end
  end

  def currency_sym
    case currency
    when "usd"
      return "$"
    when "euro"
      return "&euro;".html_safe
    when "eur"
      return "&euro;".html_safe
    when "gbp"
      return "&pound;".html_safe
    when "jpy"
      return "&yen;".html_safe
    when "ils"
      return "&#8362;".html_safe
    # when "inr"
    #   return "&#8377;".html_safe
    else
      return (currency+" ").upcase.html_safe
    end
  end


end
