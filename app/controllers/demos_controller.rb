class DemosController < ApplicationController

  before_action :throttle_demos, only: :create

  def create
    respond_to do |format| 
      format.js { }
    end

    if @limited
      @message = "You've exceeded our request limit. Please try again in a moment."
      return
    end
    @success = false
    @message = "We encountered an internal error. Sorry for the inconvenience."

    new_params = Hash.new
    new_params[:instance_name] = 'demo'
    new_params[:contact_method] = 'noemail'

    case params[:app]
    when 'rent'

      new_params[:agents_ct] = params[:input][:housemates].count
      new_params[:resources_ct] = params[:input][:rooms].count
      if new_params[:agents_ct] > 8 || new_params[:resources_ct] > 8
        return  
      end

      new_params[:rent] = params[:input][:rent]
      new_params[:currency] = 'usd'
      new_params[:rnames] = hashify(params[:input][:rooms])
      new_params[:descriptions] = hashify(new_params[:rnames].map { |r| '' })
      new_params[:types] = hashify(new_params[:rnames].map { |r| 'single' })
      new_params[:names] = hashify(params[:input][:housemates])
      new_params[:emails] = hashify(new_params[:names].map { |a| '' })
      new_params[:admin_email] = ''
      instance = splitting_rent_instance_builder(new_params)

      
    when 'goods'

      new_params[:agents_ct] = params[:input][:participants].count
      new_params[:resources_ct] = params[:input][:items].count
      if new_params[:agents_ct] > 5 || new_params[:resources_ct] > 20 # TODO: magic numbers
        return  
      end
      
      new_params[:rnames] = hashify(params[:input][:items])
      new_params[:descriptions] = hashify(new_params[:rnames].map { |r| '' })
      new_params[:types] = hashify(new_params[:rnames].map { |r| 'indivisible' })
      new_params[:names] = hashify(params[:input][:participants])
      new_params[:emails] = hashify(new_params[:names].map { |a| '' })
      new_params[:admin_email] = ''
      instance = dividing_goods_instance_builder(new_params)

    when 'credit'
      
      new_params[:agents_ct] = params[:input][:participants].count
      if new_params[:agents_ct] > 10 
        return  
      end
      new_params[:names] = hashify(params[:input][:participants])
      new_params[:emails] = hashify(new_params[:names].map { |a| '' })
      new_params[:admin_email] = ''
      instance = sharing_credit_instance_builder(new_params)
    
    when 'fare'
      new_params[:pickup] = params[:input][:pickup]
      new_params[:address_1] = params[:input][:address_1]
      new_params[:address_2] = params[:input][:address_2]
      new_params[:address_3] = params[:input][:address_3]
      new_params[:address_4] = params[:input][:address_4]
      new_params[:address_5] = params[:input][:address_5]
      new_params[:address_6] = params[:input][:address_6]
      new_params[:admin_email] = params[:input][:admin_email]
      new_params[:total_fare] = params[:input][:total_fare]
      new_params[:currency] = params[:input][:currency]

      if !new_params[:admin_email].blank? && !ValidateEmail.mx_valid?(new_params[:admin_email])
        @message = "The email address '#{new_params[:admin_email][0..50]}' is invalid."
        return
      end

      instance = splitting_fare_instance_builder(new_params)
    
    when 'tasks'

      new_params[:agents_ct] = params[:input][:participants].count
      new_params[:resources_ct] = params[:input][:tasks].count
      if new_params[:agents_ct] > 5 || new_params[:resources_ct] > 15
        return  
      end
      
      new_params[:rnames] = hashify(params[:input][:tasks])
      new_params[:quantities] = hashify(params[:input][:quantities])
      new_params[:descriptions] = hashify(new_params[:rnames].map { |r| '' })
      new_params[:types] = hashify(new_params[:rnames].map { |r| '' })
      new_params[:names] = hashify(params[:input][:participants])
      new_params[:emails] = hashify(new_params[:names].map { |a| '' })
      new_params[:admin_email] = ''
      instance = assigning_tasks_instance_builder(new_params)

    else
      return
    end

    return if !instance
    if params[:app] != 'fare'
      instance.agents.each do |agent|
        if !build_valuations_demo(agent, params[:input][:bids][agent.name])
          instance.delete
          return  
        end
      end
    end
    @passcode = instance.passcode
    @id = instance.id

    Delayed::Job.enqueue AllocationJob.new(instance.id)
    if params[:app] == 'fare'
      # fare app is somehwat slower...
      @message = "Your request is being processed. This may take up to 30 seconds.<br><img src='../../../assets/ajax-loader.gif' style='display:block;margin:0 auto;' alt = ''>".html_safe
    else
      @message = "Your request is being processed. This may take a moment.<br><img src='../../../assets/ajax-loader.gif' style='display:block;margin:0 auto;' alt = ''>".html_safe
    end
    @success = true
  end

  def poll
    respond_to do |format| 
      format.js { }
    end
    @instance = Instance.find(params[:id])
    if !@instance || @instance.passcode != params[:p] || @instance.status == 'failure'
      @status = 'failure'
    elsif @instance.status == 'complete'
      @status = 'complete'
      if @instance.application.abbr == 'rent'
        @room_for = Hash.new
        @price_for = Hash.new
        @instance.assignments.each do |a|
          @room_for[a.agent.id] = a.resource.name
          @price_for[a.agent.id] = sprintf("%0.02f", a.price)
        end
      end
    else
      @status = 'waiting'
    end
  end

  private
    def hashify(arr)
      return Hash[arr.each_with_index.map { |value, index| [index.to_s.to_sym, value] }]
    end
end
