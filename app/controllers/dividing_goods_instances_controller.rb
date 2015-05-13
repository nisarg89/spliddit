class DividingGoodsInstancesController < InstancesController
  def new
    if params[:people] == '2'
      @participants = 2
      @fixed_agents = true
      @show_types = false
      @instructions = "What is being divided? Add up to 100 items. For best results, make items as fine-grained as possible (e.g. list valuable paintings or pieces of jewelry separately)."
    else
      @participants = 3
      @fixed_agents = false
      @show_types = true
      @instructions = "What is being divided? Add up to 100 items. For best results, make items as fine-grained as possible (e.g. list valuable paintings or pieces of jewelry separately), and mark items that can easily be broken down into smaller pieces (e.g. cash, stocks) as divisible."
    end
    @resources = 3
    @resource_name = "Item"
    @resource_types = [["Not Divisible", "indivisible"], ["Divisible", "divisible"]]
    @show_quantities = false
    @show_descriptions = true
  end

  def create
    instance = dividing_goods_instance_builder(params)
    if instance && instance.separate_passwords
      flash[:success] = "<strong>Your Dividing Goods instance has been created successfully!</strong> We are in the process of sending emails to all of the addresses listed, each containing a unique, private evaluation link. Once everyone has submitted their evaluations, we'll send another email with the final results. Thanks for using Spliddit!<br><br><a href = '#{root_url}apps/goods'>Back to Dividing Goods information page</a>".html_safe
      redirect_to root_url + 'success'
    elsif instance && !instance.separate_passwords
      flash[:success] = "<strong>Your Dividing Goods instance has been created successfully!</strong> Please direct everyone participating to <a href='#{root_url}apps/goods/#{instance.id}?p=#{instance.passcode}'>#{root_url}apps/goods/#{instance.id}?p=#{instance.passcode}</a> to submit their evaluations. Please make sure you copy the link before leaving this page.".html_safe
      redirect_to root_url + 'success'
    else
      flash[:error] = "We encountered a problem when trying to create your Dividing Goods instance. (Perhaps one or more of your email addresses were invalid?) We apologize for the inconvenience. We hope you'll <a href = '#{root_url}apps/goods/new'>try again</a>, and <a href= '#{feedback_path}'>contact us</a> if the error persists.".html_safe
      redirect_to root_url + 'error'
    end
  end

  def show
    if Instance.find(params[:id]).application.abbr != "goods"
      flash[:error] = "The URL you specified is incorrect. Please ensure you have correctly copied the link."
      redirect_to root_url + 'error'
    else
      super

      @prefix = ""
      @postfix = ""
      @slider_min = 0
      @show_types = false
      @init_sum = 0
    end
  end
  
  def redirect(instance, password)
    redirect_to dividing_goods_instance_path(instance, p: password)
  end

  def two_people
  end

  def three_or_more_people
  end
end
