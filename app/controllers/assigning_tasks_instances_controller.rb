class AssigningTasksInstancesController < InstancesController
  def new
    @participants = 2
    @fixed_agents = false

    @resources = 3
    @resource_name = "Task"
    @instructions = "List each individiual task (chores, work shifts) as well as the number of times the task must be completed over the specified time frame."
    @show_types = false
    @show_descriptions = true
    @show_quantities = true    
    @resource_types = []
  end

  def create
    # TODO: factor this function out and add use the long name of the Application model
    instance = assigning_tasks_instance_builder(params)
    if instance && instance.separate_passwords
      flash[:success] = "<strong>Your Distributing Tasks instance has been created successfully!</strong> We are in the process of sending emails to all of the addresses listed, each containing a unique, private evaluation link. Once everyone has submitted their evaluations, we'll send another email with the final results. Thanks for using Spliddit!<br><br><a href = '#{root_url}apps/tasks'>Back to Dividing Goods information page</a>".html_safe
      redirect_to root_url + 'success'
    elsif instance && !instance.separate_passwords
      flash[:success] = "<strong>Your Distributing Tasks instance has been created successfully!</strong> Please direct everyone participating to <a href='#{root_url}apps/tasks/#{instance.id}?p=#{instance.passcode}'>#{root_url}apps/tasks/#{instance.id}?p=#{instance.passcode}</a> to submit their evaluations. Please make sure you copy the link before leaving this page.".html_safe
      redirect_to root_url + 'success'
    else
      flash[:error] = "We encountered a problem when trying to create your Distributing Tasks instance. (Perhaps one or more of your email addresses were invalid?) We apologize for the inconvenience. We hope you'll <a href = '#{root_url}apps/tasks/new'>try again</a>, and <a href= '#{feedback_path}'>contact us</a> if the error persists.".html_safe
      redirect_to root_url + 'error'
    end
  end

  def show
    if Instance.find(params[:id]).application.abbr != "tasks"
      flash[:error] = "The URL you specified is incorrect. Please ensure you have correctly copied the link."
      redirect_to root_url + 'error'
    else
      super

      # compute task with highest quantity for the valuations form
      @max_task = @instance.max_task
    end
  end
  
  def redirect(instance, password)
    redirect_to assigning_tasks_instance_path(instance, p: password)
  end
end
