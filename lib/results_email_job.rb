class ResultsEmailJob < Struct.new(:id, :type)
  def perform
    instance = Instance.find(id)

    if !instance.results_email_sent
      instance.toggle! :results_email_sent
      instance.agents.each do |a|
        next if (!a.send_results) || (!a.email) || (a.email=="")
        if instance.application.abbr == "rent"
          UserMailer.rent_results_email(a).deliver
        elsif instance.application.abbr == "goods"
          UserMailer.goods_results_email(a).deliver
        elsif instance.application.abbr == "credit"
          UserMailer.credit_results_email(a).deliver
        elsif instance.application.abbr == "tasks"
          UserMailer.tasks_results_email(a).deliver
        end
      end
      if instance.admin_email && instance.admin_email.length > 0
        if instance.application.abbr == "fare"
          UserMailer.fare_results_email(instance).deliver
        else
          UserMailer.admin_results_email(instance).deliver
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