class SplittingRentInstancesController < InstancesController
  
  def new
    @participants = 2
    @fixed_agents = false

    @resources = 2
    @resource_name = "Room"
    @instructions = nil
    @show_types = true
    @show_descriptions = true
    @show_quantities = false    
    @resource_types = [["Single", "single"], ["Double", "double"], 
                       ["Triple", "triple"], ["Quad", "quad"]]
  end

  def index

  end

  def create
    instance = splitting_rent_instance_builder(params)
    if instance && instance.separate_passwords
      flash[:success] = "<strong>Your instance has been created successfully!</strong> We are in the process of sending emails to all of the addresses listed, each containing a unique, private evaluation link. Once everyone has submitted their evaluations, we'll send another email with the final results. Thanks for using Spliddit!<br><br><a href = '#{root_url}apps/rent'>Back to Sharing Rent information page</a>".html_safe
      redirect_to root_url + 'success'
    elsif instance && !instance.separate_passwords
      flash[:success] = "<strong>Your instance has been created successfully!</strong> Please direct all roommates to <a href='#{root_url}apps/rent/#{instance.id}?p=#{instance.passcode}'>#{root_url}apps/rent/#{instance.id}?p=#{instance.passcode}</a> to submit their evaluations. Please make sure you copy the link before leaving this page.".html_safe
      redirect_to root_url + 'success'
    else
      flash[:error] = "We encountered a problem when trying to create your Splitting Rent instance. (Perhaps one or more of your email addresses were invalid?) We apologize for the inconvenience. We hope you'll <a href = '#{root_url}apps/rent/new'>try again</a>, and <a href= '#{feedback_path}'>contact us</a> if the error persists.".html_safe
      redirect_to root_url + 'error'
    end
  end

  def show
    if Instance.find(params[:id]).application.abbr != "rent"
      flash[:error] = "The URL you specified is incorrect. Please ensure you have correctly copied the link."
      redirect_to root_url + 'error'
    else
      super

      # get currency symbol
      @currency = @instance.currency_sym

      # used for instructions in case of double, triple, quad rooms
      @doubles = false
      @triples = false
      @quads = false
      @instance.resources.each do |r|
        @doubles = true if r.rtype == 'double'
        @triples = true if r.rtype == 'triple'
        @quads = true if r.rtype == 'quad'
      end
      @only_singles = !@doubles && !@triples && !@quads

      if @instance.complete?
        @room_for = Hash.new
        @price_for = Hash.new
        @instance.assignments.each do |a|
          @room_for[a.agent.id] = a.resource.name
          @price_for[a.agent.id] = sprintf("%0.02f", a.price)
        end
      end

      @prefix = @currency
      @postfix = ".00"
      @slider_min = 0
      @init_sum = 0
      @show_types = !@only_singles
    end
  end

  def redirect(instance, password)
    redirect_to splitting_rent_instance_path(instance, p: password)
  end
end
