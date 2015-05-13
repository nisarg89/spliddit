class UserMailer < ActionMailer::Base
  default :from => "admin@spliddit.org"
 
  def rent_init_email(agent)
    @agent = agent
    mail(:to => agent.email, :subject => "#{@agent.instance.name} - Spliddit's Sharing Rent App")
  end

  def rent_results_email(agent)
    @agent = agent
    mail(:to => agent.email, :subject => "Results for #{@agent.instance.name} - Spliddit's Sharing Rent App")
  end

  def goods_init_email(agent)
    @agent = agent
    mail(:to => agent.email, :subject => "#{@agent.instance.name} - Spliddit's Dividing Goods App")
  end

  def goods_results_email(agent)
    @agent = agent
    mail(:to => agent.email, :subject => "Results for #{@agent.instance.name} - Spliddit's Dividing Goods App")
  end

  def tasks_init_email(agent)
    @agent = agent
    mail(:to => agent.email, :subject => "#{@agent.instance.name} - Spliddit's Distributing Tasks App")
  end

  def tasks_results_email(agent)
    @agent = agent
    mail(:to => agent.email, :subject => "Results for #{@agent.instance.name} - Spliddit's Distributing Tasks App")
  end

  def credit_init_email(agent)
    @agent = agent
    mail(:to => agent.email, :subject => "#{@agent.instance.name} - Spliddit's Assigning Credit App")
  end

  def credit_results_email(agent)
    @agent = agent
    mail(:to => agent.email, :subject => "Results for #{@agent.instance.name} - Spliddit's Assigning Credit App")
  end

  def fare_results_email(instance)
    @instance = instance
    mail(:to => @instance.admin_email, :subject => "Results - Spliddit's Splitting Fare App")
  end

  def feedback_email(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(:to => "admin@spliddit.org", :subject => "Spliddit Feedback - #{name}")
  end

  def launch_email(email)
    mail(:to => email, :subject => "Spliddit has Launched!")
  end

  def admin_results_email(instance)
    @instance = instance
    email = instance.admin_email
    if instance.application.abbr == 'rent'
      @app = "Sharing Rent App"
      @url = splitting_rent_instance_url(@instance, p: @instance.passcode)
    elsif instance.application.abbr == 'goods'
      @app = "Dividing Goods App"
      @url = dividing_goods_instance_url(@instance, p: @instance.passcode)
    elsif instance.application.abbr == 'credit'
      @app = "Assigning Credit App"
      @url = sharing_credit_instance_url(@instance, p: @instance.passcode)
    else
      @app = "Distributing Tasks App"
      @url = assigning_tasks_instance_url(@instance, p: @instance.passcode)
    end
    subject = "Results for #{instance.name} - Spliddit's #{@app}"
    mail(:to => email, :subject => subject)
  end
end