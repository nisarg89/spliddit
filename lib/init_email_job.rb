class InitEmailJob < Struct.new(:id)
  def perform
    instance = Instance.find(id)

    # TODO: just have a general state property for an instance, maybe ENUM
    if !instance.init_email_sent
      instance.toggle! :init_email_sent
      instance.agents.each do |a|
        if a.email and a.email.length > 0
          if instance.application.abbr == "rent"
            UserMailer.rent_init_email(a).deliver
          elsif instance.application.abbr == "goods"
            UserMailer.goods_init_email(a).deliver
          elsif instance.application.abbr == "credit"
            UserMailer.credit_init_email(a).deliver
          elsif instance.application.abbr == "tasks"
            UserMailer.tasks_init_email(a).deliver
          end
        end
      end
    end
  end

  def max_attempts
    3
  end

  def max_run_time
    5.seconds
  end

  def default_queue_name
    "emails"
  end
end