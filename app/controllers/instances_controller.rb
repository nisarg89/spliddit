class InstancesController < ApplicationController

  before_filter :throttle_apps, only: :create

  def index

  end

  def show
    @instance = Instance.find(params[:id])
    @global_passcode = params[:p] && params[:p].length > 0 && params[:p] == @instance.passcode
    if !@global_passcode
      agents = @instance.agents.by_password(params[:p])
      @agent = agents.first unless agents.count == 0
      if !@agent then
        flash[:error] = "The URL you specified is incorrect. Please ensure you have correctly copied the link."
        redirect_to root_url + 'error'
      end
    else
      @agent = @instance.agents.first if !@instance.complete?
    end

    # used for valuations form when no separate passcodes
    @name_list = @instance.agents.map { |a| [a.name, a.name]}
  end

  def submit_valuation
    @instance = Instance.find(params[:id])

    if @instance.separate_passwords
      @agent = @instance.agents.by_password(params[:pwd]).first
    else
      @agent = @instance.agents.find_by_name(params[:name])
    end

    if !@agent then
      flash[:error] = "The URL you specified is incorrect. Please ensure you have correctly copied the link."
      redirect_to root_url + 'error'
      return
    end

    if @agent.submitted then
      flash[:error] = "You have already submitted your valuations!"
      redirect_to root_url + 'error'
      return
    end

    if params[:mailing_list]
      @agent.mailing_list = true
    else
      @agent.mailing_list = false
    end

    if params[:send_results]
      @agent.send_results = true
    else
      @agent.send_results = false
    end

    if @agent.mailing_list || @agent.send_results
      @agent.email = params[:email]
    else
      @agent.email = ""
    end

    if !@agent.save
      flash[:error] = "The email address you entered is invalid. Please press your browser's 'back' button and retry."
      redirect_to root_url + 'error'
      return
    end
    
    valuations = build_valuations(@agent, params[:values])

    if valuations
      if @instance.pending?
        Delayed::Job.enqueue AllocationJob.new(@instance.id)
      end
      redirect(@instance, @agent.passcode)
    else
      flash[:error] = "There was a problem with your submission."
      redirect_to root_url + 'error'
    end
  end

  def submit_survey
    @instance = Instance.find(params[:id])

    @agent = @instance.agents.by_password(params[:pwd]).first
    if !@agent then
      flash[:error] = "The URL you specified is incorrect. Please ensure you have correctly copied the link."
      redirect_to root_url
    end

    if @agent.submitted_survey? then
      flash[:error] = "You have already submitted the survey!"
      redirect_to root_url + 'error'
    else
      case params[:satisfaction]
      when 'vs'
        @agent.satisfaction = 4
      when 's'
        @agent.satisfaction = 3
      when 'u'
        @agent.satisfaction = 2
      when 'vu'
        @agent.satisfaction = 1
      else
        flash[:error] = "There was a problem with your feedback. Please press your browser's back button to try again."
        redirect_to root_url + 'error'
        return
      end

      if @agent.save then
        flash[:success] = "Thanks for the feedback!"
        redirect(@instance, params[:pwd])
      else 
        flash[:error] = "There was a problem with your feedback. Please press your browser's back button to try again."
        redirect_to root_url + 'error'
      end
    end
  end

  def redirect(instance, password)
    # should be overwritten in children of this base class
    redirect_to root_url
  end


end
