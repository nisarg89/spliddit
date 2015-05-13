class FeedbackJob < Struct.new(:name, :email, :message)

  def perform
    UserMailer.feedback_email(name, email, message).deliver
  end

  def max_attempts
    1
  end

  def max_run_time
    3.seconds
  end

  def default_queue_name
    "emails"
  end
end