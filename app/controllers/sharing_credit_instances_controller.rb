class SharingCreditInstancesController < InstancesController
  def new
    @participants = 4
    @fixed_agents = false
    @resources = 0
    @resource_types = []
  end

  def create
    instance = sharing_credit_instance_builder(params)
    if instance && instance.separate_passwords
      flash[:success] = "<strong>Your Assigning Credit instance has been created successfully!</strong> We are in the process of sending emails to all of the addresses listed, each containing a unique, private evaluation link. Once everyone has submitted their evaluations, we'll send another email with the final results. Thanks for using Spliddit!<br><br><a href = '#{root_url}apps/credit'>Back to Assigning Credit information page</a>".html_safe
      redirect_to root_url + 'success'
    elsif instance && !instance.separate_passwords
      flash[:success] = "<strong>Your Assigning Credit instance has been created successfully!</strong> Please direct everyone participating to <a href='#{root_url}apps/credit/#{instance.id}?p=#{instance.passcode}'>#{root_url}apps/credit/#{instance.id}?p=#{instance.passcode}</a> to submit their evaluations. Please make sure you copy the link before leaving this page.".html_safe
      redirect_to root_url + 'success'
    else
      flash[:error] = "We encountered a problem when trying to create your Assigning Credit instance. (Perhaps one or more of your email addresses were invalid?). We apologize for the inconvenience. We hope you'll <a href = '#{root_url}apps/credit/new'>try again</a>, and <a href= '#{feedback_path}'>contact us</a> if the error persists.".html_safe
      redirect_to root_url + 'error'
    end
  end

  def show
    if Instance.find(params[:id]).application.abbr != "credit"
      flash[:error] = "The URL you specified is incorrect. Please ensure you have correctly copied the link."
      redirect_to root_url + 'error'
    else
      super

      @prefix = ""
      @postfix = "%"
      @slider_min = 1
      @init_sum = @instance.agents.count - 1
      @show_types = !false
    end
  end
  

  def redirect(instance, password)
    redirect_to sharing_credit_instance_path(instance, p: password)
  end
end
